import 'dart:async';
import '../utils/app_logger.dart';

/// Servicio para gestionar el tiempo sincronizado del estado del agente
/// 
/// Este servicio mantiene un contador local que se sincroniza con el servidor
/// cada vez que se recibe una actualización del estado. Entre sincronizaciones,
/// el contador se incrementa localmente cada segundo para mantener el tiempo actualizado.
class TiempoEstadoService {
  Timer? _timer;
  DateTime? _inicioEstado;
  int _segundosBase = 0;
  
  /// Callback que se ejecuta cada vez que el tiempo se actualiza
  Function(int segundos, String formateado)? onTiempoActualizado;

  /// Inicia el contador de tiempo con los segundos del servidor
  /// 
  /// [segundosDelServidor] - Tiempo en segundos que devuelve el backend
  void iniciar(int segundosDelServidor) {
    _detenerTimer();
    
    _segundosBase = segundosDelServidor;
    _inicioEstado = DateTime.now();
    
    AppLogger.info('⏱️ Iniciando contador de tiempo: $_segundosBase segundos');
    
    // Emitir el valor inicial inmediatamente
    _emitirTiempo();
    
    // Iniciar el timer para actualizar cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _emitirTiempo();
    });
  }

  /// Sincroniza el tiempo local con el servidor
  /// 
  /// [segundosDelServidor] - Tiempo actualizado del servidor
  void sincronizar(int segundosDelServidor) {
    if (_inicioEstado == null) {
      // Si no hay estado iniciado, iniciar uno nuevo
      iniciar(segundosDelServidor);
      return;
    }
    
    // Calcular el tiempo transcurrido localmente
    final tiempoLocal = _calcularTiempoActual();
    
    // Si hay una diferencia significativa (más de 2 segundos), resincronizar
    final diferencia = (tiempoLocal - segundosDelServidor).abs();
    
    if (diferencia > 2) {
      AppLogger.info('🔄 Resincronizando tiempo: Local=$tiempoLocal, Servidor=$segundosDelServidor');
      _segundosBase = segundosDelServidor;
      _inicioEstado = DateTime.now();
    }
  }

  /// Detiene el contador de tiempo
  void detener() {
    _detenerTimer();
    _inicioEstado = null;
    _segundosBase = 0;
    AppLogger.info('⏸️ Contador de tiempo detenido');
  }

  /// Calcula el tiempo actual en segundos
  int _calcularTiempoActual() {
    if (_inicioEstado == null) return 0;
    
    final transcurrido = DateTime.now().difference(_inicioEstado!).inSeconds;
    return _segundosBase + transcurrido;
  }

  /// Emite el tiempo actual a través del callback
  void _emitirTiempo() {
    final segundos = _calcularTiempoActual();
    final formateado = _formatearTiempo(segundos);
    
    onTiempoActualizado?.call(segundos, formateado);
  }

  /// Detiene el timer interno
  void _detenerTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Formatea los segundos a formato HH:MM:SS o MM:SS
  String _formatearTiempo(int segundosTotales) {
    final horas = segundosTotales ~/ 3600;
    final minutos = (segundosTotales % 3600) ~/ 60;
    final segundos = segundosTotales % 60;
    
    if (horas > 0) {
      return '${horas.toString().padLeft(2, '0')}:'
             '${minutos.toString().padLeft(2, '0')}:'
             '${segundos.toString().padLeft(2, '0')}';
    } else {
      return '${minutos.toString().padLeft(2, '0')}:'
             '${segundos.toString().padLeft(2, '0')}';
    }
  }

  /// Obtiene el tiempo actual sin esperar al siguiente tick del timer
  /// 
  /// Retorna un Map con 'segundos' y 'formateado'
  Map<String, dynamic> obtenerTiempoActual() {
    final segundos = _calcularTiempoActual();
    final formateado = _formatearTiempo(segundos);
    
    return {
      'segundos': segundos,
      'formateado': formateado,
    };
  }

  /// Verifica si el servicio está activo
  bool get estaActivo => _timer != null && _timer!.isActive;

  /// Libera los recursos del servicio
  void dispose() {
    detener();
  }
}
