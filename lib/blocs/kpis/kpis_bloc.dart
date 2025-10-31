import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/kpis/kpis_service.dart';
import '../../utils/app_logger.dart';
import 'kpis_event.dart';
import 'kpis_state.dart';

/// BLoC para gestionar el estado de los KPIs
/// 
/// Maneja la carga de métricas y estadísticas del call center,
/// con soporte para polling automático y actualización en tiempo real.
class KPIsBloc extends Bloc<KPIsEvent, KPIsState> {
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);

  KPIsBloc() : super(const KPIsInitial()) {
    on<LoadKPIAgentes>(_onLoadKPIAgentes);
    on<LoadKPIAgenteDetalle>(_onLoadKPIAgenteDetalle);
    on<LoadKPIOverview>(_onLoadKPIOverview);
    on<LoadKPICoordinador>(_onLoadKPICoordinador);
    on<RefreshKPIs>(_onRefreshKPIs);
    on<ChangeKPIRango>(_onChangeKPIRango);
  }

  /// Maneja el evento de cargar lista de agentes KPI
  Future<void> _onLoadKPIAgentes(
    LoadKPIAgentes event,
    Emitter<KPIsState> emit,
  ) async {
    try {
      emit(const KPIsLoading());

      final agentes = await KPIsService.listarAgentes(
        role: event.role,
        isActive: event.isActive,
        search: event.search,
      );

      emit(KPIAgentesLoaded(
        agentes: agentes,
        filtroRole: event.role,
        filtroSearch: event.search,
      ));

      AppLogger.info('✅ Agentes KPI cargados: ${agentes.length}');
    } catch (e) {
      AppLogger.error('❌ Error al cargar agentes KPI: $e');
      emit(KPIsError(e.toString()));
    }
  }

  /// Maneja el evento de cargar KPI detallado de agente
  Future<void> _onLoadKPIAgenteDetalle(
    LoadKPIAgenteDetalle event,
    Emitter<KPIsState> emit,
  ) async {
    try {
      emit(const KPIsLoading());

      final detalle = await KPIsService.obtenerKPIAgente(
        documentoId: event.documentoId,
        fechaDesde: event.fechaDesde,
        fechaHasta: event.fechaHasta,
        rango: event.rango,
      );

      emit(KPIAgenteDetalleLoaded(
        detalle: detalle,
        timestamp: DateTime.now(),
      ));

      AppLogger.info('✅ KPI agente detallado cargado: ${detalle.agenteNombre}');

      // Iniciar polling automático
      _startAutoRefresh(event);
    } catch (e) {
      AppLogger.error('❌ Error al cargar KPI agente detallado: $e');
      emit(KPIsError(e.toString()));
    }
  }

  /// Maneja el evento de cargar overview de KPIs
  Future<void> _onLoadKPIOverview(
    LoadKPIOverview event,
    Emitter<KPIsState> emit,
  ) async {
    try {
      emit(const KPIsLoading());

      final overview = await KPIsService.obtenerOverview(
        fechaDesde: event.fechaDesde,
        fechaHasta: event.fechaHasta,
        campanaId: event.campanaId,
        equipoId: event.equipoId,
      );

      emit(KPIOverviewLoaded(
        overview: overview,
        timestamp: DateTime.now(),
        rangoActual: event.rango ?? 'hoy',
      ));

      AppLogger.info('✅ Overview KPI cargado: ${overview.tipoUsuario}');

      // Iniciar polling automático
      _startAutoRefresh(event);
    } catch (e) {
      AppLogger.error('❌ Error al cargar overview KPI: $e');
      emit(KPIsError(e.toString()));
    }
  }

  /// Maneja el evento de cargar KPI de coordinador
  Future<void> _onLoadKPICoordinador(
    LoadKPICoordinador event,
    Emitter<KPIsState> emit,
  ) async {
    try {
      emit(const KPIsLoading());

      final data = await KPIsService.obtenerKPICoordinador(
        fechaDesde: event.fechaDesde,
        fechaHasta: event.fechaHasta,
        equipoId: event.equipoId,
      );

      emit(KPICoordinadorLoaded(
        data: data,
        timestamp: DateTime.now(),
      ));

      AppLogger.info('✅ KPI coordinador cargado');

      // Iniciar polling automático
      _startAutoRefresh(event);
    } catch (e) {
      AppLogger.error('❌ Error al cargar KPI coordinador: $e');
      emit(KPIsError(e.toString()));
    }
  }

  /// Maneja el evento de refrescar KPIs
  Future<void> _onRefreshKPIs(
    RefreshKPIs event,
    Emitter<KPIsState> emit,
  ) async {
    final currentState = state;

    try {
      // No emitir loading para el refresh silencioso
      if (currentState is KPIAgenteDetalleLoaded) {
        // Recargar el mismo agente
        final detalle = await KPIsService.obtenerKPIAgente(
          documentoId: currentState.detalle.agenteId,
        );

        emit(KPIAgenteDetalleLoaded(
          detalle: detalle,
          timestamp: DateTime.now(),
        ));

        AppLogger.info('🔄 KPI agente actualizado');
      } else if (currentState is KPIOverviewLoaded) {
        // Recargar overview (usa fecha de hoy por defecto)
        final overview = await KPIsService.obtenerOverview();

        emit(currentState.copyWith(
          overview: overview,
          timestamp: DateTime.now(),
        ));

        AppLogger.info('🔄 Overview KPI actualizado');
      } else if (currentState is KPICoordinadorLoaded) {
        // Recargar KPI coordinador
        final data = await KPIsService.obtenerKPICoordinador();

        emit(KPICoordinadorLoaded(
          data: data,
          timestamp: DateTime.now(),
        ));

        AppLogger.info('🔄 KPI coordinador actualizado');
      }
    } catch (e) {
      AppLogger.error('❌ Error al refrescar KPIs: $e');

      // Preservar el estado anterior en caso de error
      emit(KPIsError(
        e.toString(),
        previousState: currentState,
      ));
    }
  }

  /// Maneja el evento de cambiar rango de fechas
  Future<void> _onChangeKPIRango(
    ChangeKPIRango event,
    Emitter<KPIsState> emit,
  ) async {
    final currentState = state;

    if (currentState is KPIOverviewLoaded) {
      try {
        emit(const KPIsLoading());

        final overview = await KPIsService.obtenerOverview(
          fechaDesde: event.fechaDesde,
          fechaHasta: event.fechaHasta,
        );

        emit(KPIOverviewLoaded(
          overview: overview,
          timestamp: DateTime.now(),
          rangoActual: event.rango,
        ));

        AppLogger.info('✅ Rango cambiado a: ${event.rango}');
      } catch (e) {
        AppLogger.error('❌ Error al cambiar rango: $e');
        emit(KPIsError(e.toString(), previousState: currentState));
      }
    }
  }

  /// Inicia el refresco automático de KPIs cada 30 segundos
  void _startAutoRefresh(KPIsEvent event) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      add(const RefreshKPIs());
    });
    AppLogger.info('⏱️ Polling de KPIs iniciado (cada ${_refreshInterval.inSeconds}s)');
  }

  /// Detiene el refresco automático de KPIs
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    AppLogger.info('⏸️ Polling de KPIs detenido');
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
