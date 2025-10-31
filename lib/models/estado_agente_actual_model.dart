/// Modelo para el estado actual del agente en tiempo real
/// 
/// Este modelo representa el estado actual de un agente, incluyendo
/// el tiempo que lleva en ese estado y otra información relevante.
class EstadoAgenteActualModel {
  /// ID del agente
  final String agenteId;
  
  /// Nombre completo del agente
  final String agenteNombre;
  
  /// ID del estado actual
  final int estadoId;
  
  /// Valor del estado (DISPONIBLE, EN_LLAMADA, etc.)
  final String estadoValor;
  
  /// Timestamp de cuándo se inició este estado
  final DateTime tiempo;
  
  /// Tiempo transcurrido en este estado (en segundos)
  final int tiempoEnEstadoSegundos;
  
  /// Tiempo formateado (HH:MM:SS o MM:SS)
  final String tiempoEnEstadoFormateado;
  
  /// Última actualización del registro
  final DateTime ultimaActualizacion;

  EstadoAgenteActualModel({
    required this.agenteId,
    required this.agenteNombre,
    required this.estadoId,
    required this.estadoValor,
    required this.tiempo,
    required this.tiempoEnEstadoSegundos,
    required this.tiempoEnEstadoFormateado,
    required this.ultimaActualizacion,
  });

  /// Factory constructor para crear desde JSON
  factory EstadoAgenteActualModel.fromJson(Map<String, dynamic> json) {
    return EstadoAgenteActualModel(
      agenteId: json['agente_id']?.toString() ?? '',
      agenteNombre: json['agente_nombre']?.toString() ?? '',
      estadoId: (json['estado_id'] as num?)?.toInt() ?? 0,
      estadoValor: json['estado_valor']?.toString() ?? '',
      tiempo: json['tiempo'] != null 
        ? DateTime.parse(json['tiempo'].toString()) 
        : DateTime.now(),
      tiempoEnEstadoSegundos: (json['tiempo_en_estado_segundos'] as num?)?.toInt() ?? 0,
      tiempoEnEstadoFormateado: json['tiempo_en_estado_formateado']?.toString() ?? '00:00',
      ultimaActualizacion: json['ultima_actualizacion'] != null 
        ? DateTime.parse(json['ultima_actualizacion'].toString()) 
        : DateTime.now(),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'agente_id': agenteId,
      'agente_nombre': agenteNombre,
      'estado_id': estadoId,
      'estado_valor': estadoValor,
      'tiempo': tiempo.toIso8601String(),
      'tiempo_en_estado_segundos': tiempoEnEstadoSegundos,
      'tiempo_en_estado_formateado': tiempoEnEstadoFormateado,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
    };
  }

  /// Crea una copia del modelo con algunos campos modificados
  EstadoAgenteActualModel copyWith({
    String? agenteId,
    String? agenteNombre,
    int? estadoId,
    String? estadoValor,
    DateTime? tiempo,
    int? tiempoEnEstadoSegundos,
    String? tiempoEnEstadoFormateado,
    DateTime? ultimaActualizacion,
  }) {
    return EstadoAgenteActualModel(
      agenteId: agenteId ?? this.agenteId,
      agenteNombre: agenteNombre ?? this.agenteNombre,
      estadoId: estadoId ?? this.estadoId,
      estadoValor: estadoValor ?? this.estadoValor,
      tiempo: tiempo ?? this.tiempo,
      tiempoEnEstadoSegundos: tiempoEnEstadoSegundos ?? this.tiempoEnEstadoSegundos,
      tiempoEnEstadoFormateado: tiempoEnEstadoFormateado ?? this.tiempoEnEstadoFormateado,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }

  /// Verifica si el agente está disponible
  bool get isDisponible => estadoValor.toUpperCase() == 'DISPONIBLE';

  /// Verifica si el agente está en llamada
  bool get isEnLlamada => estadoValor.toUpperCase() == 'EN_LLAMADA';

  /// Verifica si el agente está en postcall
  bool get isPostcall => estadoValor.toUpperCase() == 'POSTCALL';

  /// Verifica si el agente está desconectado
  bool get isDesconectado => estadoValor.toUpperCase() == 'DESCONECTADO';
}
