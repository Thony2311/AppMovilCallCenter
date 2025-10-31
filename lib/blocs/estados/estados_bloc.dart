import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/user_service.dart';
import '../../utils/app_logger.dart';
import 'estados_event.dart';
import 'estados_state.dart';

/// BLoC para gestionar el estado de los agentes en tiempo real
/// 
/// Maneja la carga del estado actual del agente, agentes disponibles,
/// y refresco automático del estado (polling cada 30 segundos).
class EstadosBloc extends Bloc<EstadosEvent, EstadosState> {
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);

  EstadosBloc() : super(const EstadosInitial()) {
    on<LoadEstadoActual>(_onLoadEstadoActual);
    on<LoadAgentesDisponibles>(_onLoadAgentesDisponibles);
    on<LoadTodosLosEstados>(_onLoadTodosLosEstados);
    on<RefreshEstado>(_onRefreshEstado);
  }

  /// Maneja el evento de cargar el estado actual del agente
  Future<void> _onLoadEstadoActual(
    LoadEstadoActual event,
    Emitter<EstadosState> emit,
  ) async {
    try {
      emit(const EstadosLoading());

      final estadoActual = await UserService.obtenerEstadoActual();

      emit(EstadoActualLoaded(
        estadoActual: estadoActual,
        timestamp: DateTime.now(),
      ));

      AppLogger.info('✅ Estado actual cargado: ${estadoActual.estadoValor}');

      // Iniciar polling automático si no está activo
      _startAutoRefresh();
    } catch (e) {
      AppLogger.error('❌ Error al cargar estado actual: $e');
      emit(EstadosError(e.toString()));
    }
  }

  /// Maneja el evento de cargar agentes disponibles
  Future<void> _onLoadAgentesDisponibles(
    LoadAgentesDisponibles event,
    Emitter<EstadosState> emit,
  ) async {
    try {
      emit(const EstadosLoading());

      final agentes = await UserService.obtenerAgentesDisponibles();

      emit(AgentesDisponiblesLoaded(
        agentes: agentes,
      ));

      AppLogger.info('✅ Agentes disponibles cargados: ${agentes.length}');
    } catch (e) {
      AppLogger.error('❌ Error al cargar agentes disponibles: $e');
      emit(EstadosError(e.toString()));
    }
  }

  /// Maneja el evento de cargar todos los estados disponibles
  Future<void> _onLoadTodosLosEstados(
    LoadTodosLosEstados event,
    Emitter<EstadosState> emit,
  ) async {
    try {
      emit(const EstadosLoading());

      final estados = await UserService.obtenerTodosLosEstados();

      emit(TodosLosEstadosLoaded(estados));

      AppLogger.info('✅ Todos los estados cargados: ${estados.length}');
    } catch (e) {
      AppLogger.error('❌ Error al cargar todos los estados: $e');
      emit(EstadosError(e.toString()));
    }
  }

  /// Maneja el evento de refrescar el estado actual (polling)
  Future<void> _onRefreshEstado(
    RefreshEstado event,
    Emitter<EstadosState> emit,
  ) async {
    final currentState = state;

    try {
      // No emitir loading para el refresh silencioso
      final estadoActual = await UserService.obtenerEstadoActual();

      // Verificar si el estado cambió
      bool estadoCambio = false;
      if (currentState is EstadoActualLoaded) {
        estadoCambio = currentState.estadoActual.estadoValor != estadoActual.estadoValor;
      }

      emit(EstadoActualLoaded(
        estadoActual: estadoActual,
        timestamp: DateTime.now(),
      ));

      if (estadoCambio) {
        AppLogger.info('🔄 Estado cambió a: ${estadoActual.estadoValor}');
      }
    } catch (e) {
      AppLogger.error('❌ Error al refrescar estado: $e');
      
      // Preservar el estado anterior si falla el refresh
      if (currentState is EstadoActualLoaded) {
        emit(EstadosError(
          e.toString(),
          previousEstado: currentState.estadoActual,
        ));
      } else {
        emit(EstadosError(e.toString()));
      }
    }
  }

  /// Inicia el refresco automático del estado cada 30 segundos
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      add(const RefreshEstado());
    });
    AppLogger.info('⏱️ Polling de estado iniciado (cada ${_refreshInterval.inSeconds}s)');
  }

  /// Detiene el refresco automático del estado
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    AppLogger.info('⏸️ Polling de estado detenido');
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
