/// Modelo para top agentes
class TopAgenteModel {
  final String agenteId;
  final String agenteNombre;
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion;

  TopAgenteModel({
    required this.agenteId,
    required this.agenteNombre,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
  });

  factory TopAgenteModel.fromJson(Map<String, dynamic> json) {
    return TopAgenteModel(
      agenteId: json['agente_id']?.toString() ?? '',
      agenteNombre: json['agente_nombre']?.toString() ?? '',
      totalLlamadas: (json['total_llamadas'] as num?)?.toInt() ?? 0,
      ventasRealizadas: (json['ventas_realizadas'] as num?)?.toInt() ?? 0,
      tasaConversion: (json['tasa_conversion'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agente_id': agenteId,
      'agente_nombre': agenteNombre,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
    };
  }

  /// Formato de tasa de conversión con porcentaje
  String get tasaConversionFormateada => '${tasaConversion.toStringAsFixed(2)}%';

  /// Verifica si tiene ventas
  bool get tieneVentas => ventasRealizadas > 0;
}
