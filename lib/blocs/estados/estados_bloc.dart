import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/user_service.dart';
import '../../services/tiempo_estado_service.dart';
import '../../utils/app_logger.dart';
import 'estados_event.dart';
import 'estados_state.dart';

/// BLoC para gestionar el estado de los agentes en tiempo real
/// 
/// ## Funcionamiento de la sincronización:
/// 
/// 1. **Polling sincronizado**: Las consultas al servidor se hacen en intervalos
///    de 30 segundos alineados con el reloj (00:00, 00:30, 01:00, 01:30, etc.)
///    para evitar consultas en momentos aleatorios.
/// 
/// 2. **Contador local**: Entre consultas, un timer actualiza el contador cada
///    segundo para mantener la UI fluida sin sobrecargar el servidor.
/// 
/// 3. **Re-sincronización**: Cuando cambia el estado del agente, se reinicia
///    el polling para mantener la sincronización con intervalos de 30s.
/// 
/// 4. **Corrección de desfases**: Si el tiempo local difiere del servidor en
///    más de 2 segundos, se ajusta automáticamente.
class EstadosBloc extends Bloc<EstadosEvent, EstadosState> {
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);
  final UserServiceInterface? _userService;
  final TiempoEstadoService _tiempoService = TiempoEstadoService();

  EstadosBloc({UserServiceInterface? service}) 
      : _userService = service,
        super(const EstadosInitial()) {
    on<LoadEstadoActual>(_onLoadEstadoActual);
    on<LoadAgentesDisponibles>(_onLoadAgentesDisponibles);
    on<LoadTodosLosEstados>(_onLoadTodosLosEstados);
    on<RefreshEstado>(_onRefreshEstado);
    on<UpdateTiempoLocal>(_onUpdateTiempoLocal);
    
    // Configurar callback del servicio de tiempo
    _tiempoService.onTiempoActualizado = (segundos, formateado) {
      add(UpdateTiempoLocal(segundos: segundos, tiempoFormateado: formateado));
    };
  }

  /// Maneja el evento de cargar el estado actual del agente
  Future<void> _onLoadEstadoActual(
    LoadEstadoActual event,
    Emitter<EstadosState> emit,
  ) async {
    try {
      emit(const EstadosLoading());

      // 🔥 CORRECCIÓN: Usar servicio inyectado O método estático
      final estadoActual = _userService != null
          ? await _userService.obtenerEstadoActualInstance()
          : await UserService.obtenerEstadoActual();

      // Iniciar sincronización del tiempo con el servidor
      _tiempoService.iniciar(estadoActual.tiempoEnEstadoSegundos);

      emit(EstadoActualLoaded(
        estadoActual: estadoActual,
        timestamp: DateTime.now(),
        tiempoLocalSegundos: estadoActual.tiempoEnEstadoSegundos,
        tiempoLocalFormateado: estadoActual.tiempoEnEstadoFormateado,
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

      // 🔥 CORRECCIÓN: Usar servicio inyectado O método estático
      final agentes = _userService != null
          ? await _userService.obtenerAgentesDisponiblesInstance()
          : await UserService.obtenerAgentesDisponibles();

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

      // 🔥 CORRECCIÓN: Usar servicio inyectado O método estático
      final estados = _userService != null
          ? await _userService.obtenerTodosLosEstadosInstance()
          : await UserService.obtenerTodosLosEstados();

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
      // 🔥 CORRECCIÓN: Usar servicio inyectado O método estático
      final estadoActual = _userService != null
          ? await _userService.obtenerEstadoActualInstance()
          : await UserService.obtenerEstadoActual();

      // Verificar si el estado cambió
      bool estadoCambio = false;
      if (currentState is EstadoActualLoaded) {
        estadoCambio = currentState.estadoActual.estadoValor != estadoActual.estadoValor;
        
        if (estadoCambio) {
          // Si cambió el estado, reiniciar el contador y resincronizar polling
          AppLogger.info('🔄 Estado cambió a: ${estadoActual.estadoValor}');
          _tiempoService.iniciar(estadoActual.tiempoEnEstadoSegundos);
          
          // Resincronizar el polling después de un cambio de estado
          _startAutoRefresh();
        } else {
          // Si no cambió, solo sincronizar el tiempo
          _tiempoService.sincronizar(estadoActual.tiempoEnEstadoSegundos);
        }
      }

      emit(EstadoActualLoaded(
        estadoActual: estadoActual,
        timestamp: DateTime.now(),
        tiempoLocalSegundos: estadoActual.tiempoEnEstadoSegundos,
        tiempoLocalFormateado: estadoActual.tiempoEnEstadoFormateado,
      ));
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

  /// Maneja el evento de actualizar el tiempo local
  void _onUpdateTiempoLocal(
    UpdateTiempoLocal event,
    Emitter<EstadosState> emit,
  ) {
    final currentState = state;
    
    // Solo actualizar si estamos en estado EstadoActualLoaded
    if (currentState is EstadoActualLoaded) {
      emit(currentState.copyWithTiempo(
        segundos: event.segundos,
        formateado: event.tiempoFormateado,
      ));
    }
  }

  /// Inicia el refresco automático del estado cada 30 segundos
  /// Sincronizado con intervalos de 30 segundos desde el inicio de cada minuto
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    
    // Calcular el tiempo hasta el próximo intervalo de 30 segundos
    final now = DateTime.now();
    final segundosActuales = now.second;
    
    // Próximo intervalo: 0s o 30s del minuto
    int segundosHastaProximoIntervalo;
    if (segundosActuales < 30) {
      segundosHastaProximoIntervalo = 30 - segundosActuales;
    } else {
      segundosHastaProximoIntervalo = 60 - segundosActuales;
    }
    
    AppLogger.info('⏱️ Primera consulta en $segundosHastaProximoIntervalo segundos, luego cada 30s');
    
    // Programar primera consulta en el próximo intervalo
    _refreshTimer = Timer(Duration(seconds: segundosHastaProximoIntervalo), () {
      add(const RefreshEstado());
      
      // Después de la primera consulta sincronizada, usar Timer.periodic
      _refreshTimer?.cancel();
      _refreshTimer = Timer.periodic(_refreshInterval, (_) {
        add(const RefreshEstado());
      });
      AppLogger.info('⏱️ Polling periódico iniciado (cada ${_refreshInterval.inSeconds}s)');
    });
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
    _tiempoService.dispose();
    return super.close();
  }
}