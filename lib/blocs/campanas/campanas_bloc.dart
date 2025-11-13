import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/campanas/campana_model.dart';
import '../../services/campanas_service.dart';
import '../../utils/app_logger.dart';
import 'campanas_event.dart';
import 'campanas_state.dart';

/// BLoC para gestionar el estado de las campañas
/// 
/// Maneja la carga, filtrado y paginación de campañas del call center.
class CampanasBloc extends Bloc<CampanasEvent, CampanasState> {
  final CampanasServiceInterface? _campanasService;

  CampanasBloc({CampanasServiceInterface? service}) 
      : _campanasService = service,
        super(const CampanasInitial()) {
    on<LoadCampanas>(_onLoadCampanas);
    on<LoadCampanaById>(_onLoadCampanaById);
    on<LoadCampanasActivas>(_onLoadCampanasActivas);
    on<FilterCampanasByEstado>(_onFilterCampanasByEstado);
    on<LoadMoreCampanas>(_onLoadMoreCampanas);
    on<RefreshCampanas>(_onRefreshCampanas);
  }

  /// Maneja el evento de cargar campañas con filtros
  Future<void> _onLoadCampanas(
    LoadCampanas event,
    Emitter<CampanasState> emit,
  ) async {
    try {
      emit(const CampanasLoading());

      // 🔥 CORRECCIÓN: Usar servicio inyectado O método estático
      final Map<String, dynamic> resultado;
      if (_campanasService != null) {
        resultado = await _campanasService.listarCampanasInstance(
          estado: event.estado,
          jefeCampana: event.jefeCampana,
          centro: event.centro,
          page: event.page,
        );
      } else {
        resultado = await CampanasService.listarCampanas(
          estado: event.estado,
          jefeCampana: event.jefeCampana,
          centro: event.centro,
          page: event.page,
        );
      }

      final campanas = (resultado['campanas'] as List).cast<CampanaModel>();
      final count = resultado['count'] as int;
      final hasMore = resultado['next'] != null;

      emit(CampanasLoaded(
        campanas: campanas,
        totalCount: count,
        hasMore: hasMore,
        currentPage: event.page,
        filtroEstado: event.estado,
      ));

      AppLogger.info('✅ Campañas cargadas exitosamente: ${campanas.length} de $count');
    } catch (e) {
      AppLogger.error('❌ Error al cargar campañas: $e');
      emit(CampanasError(e.toString()));
    }
  }

  /// Maneja el evento de cargar una campaña específica
  Future<void> _onLoadCampanaById(
    LoadCampanaById event,
    Emitter<CampanasState> emit,
  ) async {
    try {
      emit(const CampanasLoading());

      // 🔥 CORRECCIÓN: Usar servicio inyectado O método estático
      final CampanaModel campana;
      if (_campanasService != null) {
        campana = await _campanasService.obtenerCampanaInstance(event.campanaId);
      } else {
        campana = await CampanasService.obtenerCampana(event.campanaId);
      }

      emit(CampanaDetailLoaded(campana));

      AppLogger.info('✅ Campaña #${event.campanaId} cargada exitosamente');
    } catch (e) {
      AppLogger.error('❌ Error al cargar campaña #${event.campanaId}: $e');
      emit(CampanasError(e.toString()));
    }
  }

  /// Maneja el evento de cargar solo campañas activas
  Future<void> _onLoadCampanasActivas(
    LoadCampanasActivas event,
    Emitter<CampanasState> emit,
  ) async {
    try {
      emit(const CampanasLoading());

      // 🔥 CORRECCIÓN: Usar servicio inyectado O método estático
      final List<CampanaModel> campanas;
      if (_campanasService != null) {
        campanas = await _campanasService.listarCampanasActivasInstance();
      } else {
        campanas = await CampanasService.listarCampanasActivas();
      }

      emit(CampanasLoaded(
        campanas: campanas,
        totalCount: campanas.length,
        hasMore: false,
        filtroEstado: 'ACTIVA',
      ));

      AppLogger.info('✅ Campañas activas cargadas: ${campanas.length}');
    } catch (e) {
      AppLogger.error('❌ Error al cargar campañas activas: $e');
      emit(CampanasError(e.toString()));
    }
  }

  /// Maneja el evento de filtrar campañas por estado
  Future<void> _onFilterCampanasByEstado(
    FilterCampanasByEstado event,
    Emitter<CampanasState> emit,
  ) async {
    try {
      emit(const CampanasLoading());

      // 🔥 CORRECCIÓN: Usar servicio inyectado O método estático
      final Map<String, dynamic> resultado;
      if (_campanasService != null) {
        resultado = await _campanasService.listarCampanasInstance(estado: event.estado);
      } else {
        resultado = await CampanasService.listarCampanas(estado: event.estado);
      }

      final campanas = (resultado['campanas'] as List).cast<CampanaModel>();
      final count = resultado['count'] as int;
      final hasMore = resultado['next'] != null;

      emit(CampanasLoaded(
        campanas: campanas,
        totalCount: count,
        hasMore: hasMore,
        filtroEstado: event.estado,
      ));

      AppLogger.info('✅ Campañas filtradas por estado "${event.estado}": ${campanas.length}');
    } catch (e) {
      AppLogger.error('❌ Error al filtrar campañas: $e');
      emit(CampanasError(e.toString()));
    }
  }

  /// Maneja el evento de cargar más campañas (paginación)
  Future<void> _onLoadMoreCampanas(
    LoadMoreCampanas event,
    Emitter<CampanasState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CampanasLoaded) return;
    if (!currentState.hasMore) return;

    try {
      emit(CampanasLoadingMore(currentState.campanas));

      final nextPage = currentState.currentPage + 1;

      // 🔥 CORRECCIÓN: Usar servicio inyectado O método estático
      final Map<String, dynamic> resultado;
      if (_campanasService != null) {
        resultado = await _campanasService.listarCampanasInstance(
          estado: currentState.filtroEstado,
          page: nextPage,
        );
      } else {
        resultado = await CampanasService.listarCampanas(
          estado: currentState.filtroEstado,
          page: nextPage,
        );
      }

      final newCampanas = (resultado['campanas'] as List).cast<CampanaModel>();
      final allCampanas = [...currentState.campanas, ...newCampanas];
      final hasMore = resultado['next'] != null;

      emit(currentState.copyWith(
        campanas: allCampanas,
        hasMore: hasMore,
        currentPage: nextPage,
      ));

      AppLogger.info('✅ Más campañas cargadas: ${newCampanas.length} (total: ${allCampanas.length})');
    } catch (e) {
      AppLogger.error('❌ Error al cargar más campañas: $e');
      emit(CampanasError(
        e.toString(),
        previousCampanas: currentState.campanas,
      ));
    }
  }

  /// Maneja el evento de refrescar la lista
  Future<void> _onRefreshCampanas(
    RefreshCampanas event,
    Emitter<CampanasState> emit,
  ) async {
    final currentState = state;
    String? filtroEstado;

    if (currentState is CampanasLoaded) {
      filtroEstado = currentState.filtroEstado;
    }

    // Recargar desde la primera página
    add(LoadCampanas(estado: filtroEstado));
  }
}