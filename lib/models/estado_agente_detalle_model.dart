/// Modelo para el historial de estados del agente por día
/// 
/// Este modelo representa el tiempo acumulado que un agente ha estado
/// en un estado específico durante un día.
class EstadoAgenteDetalleModel {
  /// ID del registro
  final int id;
  
  /// ID del agente
  final String agenteId;
  
  /// Nombre completo del agente
  final String agenteNombre;
  
  /// ID del estado
  final int estadoId;
  
  /// Valor del estado (DISPONIBLE, EN_LLAMADA, etc.)
  final String estadoValor;
  
  /// Tiempo total acumulado en el día en formato HH:MM:SS
  final String tiempo;
  
  /// Fecha del registro
  final DateTime fecha;
  
  /// Historial de cambios del día: "HH:MM:SS - nombre_usuario, ..."
  final String? cambios;

  EstadoAgenteDetalleModel({
    required this.id,
    required this.agenteId,
    required this.agenteNombre,
    required this.estadoId,
    required this.estadoValor,
    required this.tiempo,
    required this.fecha,
    this.cambios,
  });

  /// Factory constructor para crear desde JSON
  factory EstadoAgenteDetalleModel.fromJson(Map<String, dynamic> json) {
    return EstadoAgenteDetalleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      agenteId: json['agente_id']?.toString() ?? '',
      agenteNombre: json['agente_nombre']?.toString() ?? '',
      estadoId: (json['estado_id'] as num?)?.toInt() ?? 0,
      estadoValor: json['estado_valor']?.toString() ?? '',
      tiempo: json['tiempo']?.toString() ?? '00:00:00',
      fecha: json['fecha'] != null 
        ? DateTime.parse(json['fecha'].toString()) 
        : DateTime.now(),
      cambios: json['cambios']?.toString(),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agente_id': agenteId,
      'agente_nombre': agenteNombre,
      'estado_id': estadoId,
      'estado_valor': estadoValor,
      'tiempo': tiempo,
      'fecha': fecha.toIso8601String(),
      'cambios': cambios,
    };
  }

  /// Convierte el tiempo HH:MM:SS a segundos
  int get tiempoEnSegundos {
    try {
      final parts = tiempo.split(':');
      if (parts.length != 3) return 0;
      
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);
      
      return (hours * 3600) + (minutes * 60) + seconds;
    } catch (e) {
      return 0;
    }
  }

  /// Formatea el tiempo de manera legible
  String get tiempoFormateado => tiempo;
}
