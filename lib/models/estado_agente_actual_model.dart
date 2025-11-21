/// Modelo para el estado actual del agente en tiempo real
/// 
/// Este modelo representa el estado actual de un agente, incluyendo
/// el tiempo que lleva en ese estado y otra información relevante.
class EstadoAgenteActualModel {
  /// ID del agente (documento de identidad)
  final String agenteId;
  
  /// Nombre completo del agente
  final String agenteNombre;
  
  /// Email del agente
  final String? agenteEmail;
  
  /// ID del estado actual
  final int estadoId;
  
  /// Valor del estado (DISPONIBLE, EN_LLAMADA, AFTERCALL, etc.)
  final String estadoValor;
  
  /// Descripción legible del estado
  final String? estadoDisplay;
  
  /// Timestamp de cuándo se inició este estado
  final DateTime tiempo;
  
  /// Última actualización del registro
  final DateTime ultimaActualizacion;
  
  /// Segundos transcurridos en el estado actual (del backend)
  final int duracionActual;
  
  /// ID de la campaña actual asignada al agente
  final int? campanaActualId;
  
  /// Indica si el agente acepta llamadas (true solo si DISPONIBLE)
  final bool aceptaLlamadas;
  
  /// Indica si el agente tiene conexión activa
  final bool conexionActiva;
  
  /// Indica si el agente tiene audio habilitado
  final bool tieneAudio;
  
  /// Indica si el agente puede recibir llamadas
  final bool puedeRecibirLlamadas;

  /// Alias de duracionActual para compatibilidad (en segundos)
  int get tiempoEnEstadoSegundos => duracionActual;
  
  /// Tiempo formateado dinámicamente (HH:MM:SS o MM:SS)
  String get tiempoEnEstadoFormateado => _formatearTiempo(duracionActual);

  EstadoAgenteActualModel({
    required this.agenteId,
    required this.agenteNombre,
    this.agenteEmail,
    required this.estadoId,
    required this.estadoValor,
    this.estadoDisplay,
    required this.tiempo,
    required this.ultimaActualizacion,
    required this.duracionActual,
    this.campanaActualId,
    required this.aceptaLlamadas,
    required this.conexionActiva,
    required this.tieneAudio,
    required this.puedeRecibirLlamadas,
  });

  /// Factory constructor para crear desde JSON
  factory EstadoAgenteActualModel.fromJson(Map<String, dynamic> json) {
    // El backend envía tanto 'duracion_actual' como 'tiempo_en_estado'
    // Usar el que esté disponible (son alias)
    final duracion = (json['duracion_actual'] as num?)?.toInt() ?? 
                     (json['tiempo_en_estado'] as num?)?.toInt() ?? 0;
    
    return EstadoAgenteActualModel(
      agenteId: json['agente_id']?.toString() ?? '',
      agenteNombre: json['agente_nombre']?.toString() ?? '',
      agenteEmail: json['agente_email']?.toString(),
      estadoId: (json['estado_id'] as num?)?.toInt() ?? 0,
      estadoValor: (json['estado_valor'] ?? json['estado'])?.toString() ?? '',
      estadoDisplay: json['estado_display']?.toString(),
      tiempo: json['tiempo'] != null 
        ? DateTime.parse(json['tiempo'].toString()) 
        : DateTime.now(),
      ultimaActualizacion: json['ultima_actualizacion'] != null 
        ? DateTime.parse(json['ultima_actualizacion'].toString()) 
        : DateTime.now(),
      duracionActual: duracion,
      campanaActualId: (json['campana_actual_id'] as num?)?.toInt(),
      aceptaLlamadas: json['acepta_llamadas'] == true,
      conexionActiva: json['conexion_activa'] == true,
      tieneAudio: json['tiene_audio'] == true,
      puedeRecibirLlamadas: json['puede_recibir_llamadas'] == true,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'agente_id': agenteId,
      'agente_nombre': agenteNombre,
      'agente_email': agenteEmail,
      'estado_id': estadoId,
      'estado_valor': estadoValor,
      'estado': estadoValor, // Alias para compatibilidad
      'estado_display': estadoDisplay,
      'tiempo': tiempo.toIso8601String(),
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'duracion_actual': duracionActual,
      'tiempo_en_estado': duracionActual, // Alias para compatibilidad
      'campana_actual_id': campanaActualId,
      'acepta_llamadas': aceptaLlamadas,
      'conexion_activa': conexionActiva,
      'tiene_audio': tieneAudio,
      'puede_recibir_llamadas': puedeRecibirLlamadas,
    };
  }

  /// Crea una copia del modelo con algunos campos modificados
  EstadoAgenteActualModel copyWith({
    String? agenteId,
    String? agenteNombre,
    String? agenteEmail,
    int? estadoId,
    String? estadoValor,
    String? estadoDisplay,
    DateTime? tiempo,
    DateTime? ultimaActualizacion,
    int? duracionActual,
    int? campanaActualId,
    bool? aceptaLlamadas,
    bool? conexionActiva,
    bool? tieneAudio,
    bool? puedeRecibirLlamadas,
  }) {
    return EstadoAgenteActualModel(
      agenteId: agenteId ?? this.agenteId,
      agenteNombre: agenteNombre ?? this.agenteNombre,
      agenteEmail: agenteEmail ?? this.agenteEmail,
      estadoId: estadoId ?? this.estadoId,
      estadoValor: estadoValor ?? this.estadoValor,
      estadoDisplay: estadoDisplay ?? this.estadoDisplay,
      tiempo: tiempo ?? this.tiempo,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      duracionActual: duracionActual ?? this.duracionActual,
      campanaActualId: campanaActualId ?? this.campanaActualId,
      aceptaLlamadas: aceptaLlamadas ?? this.aceptaLlamadas,
      conexionActiva: conexionActiva ?? this.conexionActiva,
      tieneAudio: tieneAudio ?? this.tieneAudio,
      puedeRecibirLlamadas: puedeRecibirLlamadas ?? this.puedeRecibirLlamadas,
    );
  }

  /// Formatea los segundos a formato HH:MM:SS o MM:SS
  static String _formatearTiempo(int segundosTotales) {
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

  /// Verifica si el agente está disponible
  bool get isDisponible => estadoValor.toUpperCase() == 'DISPONIBLE';

  /// Verifica si el agente está en llamada
  bool get isEnLlamada => estadoValor.toUpperCase() == 'EN_LLAMADA';

  /// Verifica si el agente está en postcall/aftercall
  bool get isPostcall => estadoValor.toUpperCase() == 'POSTCALL' || 
                         estadoValor.toUpperCase() == 'AFTERCALL';

  /// Verifica si el agente está desconectado
  bool get isDesconectado => estadoValor.toUpperCase() == 'DESCONECTADO';
}
