/// Modelo resumen de equipo (usado en CampanaKPIModel)
class EquipoResumenModel {
  final int equipoId;
  final String equipoNombre;
  final String? coordinadorNombre;
  final int totalAgentes;
  final int totalLlamadas;
  final int ventasRealizadas;

  EquipoResumenModel({
    required this.equipoId,
    required this.equipoNombre,
    this.coordinadorNombre,
    required this.totalAgentes,
    required this.totalLlamadas,
    required this.ventasRealizadas,
  });

  factory EquipoResumenModel.fromJson(Map<String, dynamic> json) {
    return EquipoResumenModel(
      equipoId: (json['equipo_id'] as num?)?.toInt() ?? 0,
      equipoNombre: json['equipo_nombre']?.toString() ?? '',
      coordinadorNombre: json['coordinador_nombre']?.toString(),
      totalAgentes: (json['total_agentes'] as num?)?.toInt() ?? 0,
      totalLlamadas: (json['total_llamadas'] as num?)?.toInt() ?? 0,
      ventasRealizadas: (json['ventas_realizadas'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipo_id': equipoId,
      'equipo_nombre': equipoNombre,
      'coordinador_nombre': coordinadorNombre,
      'total_agentes': totalAgentes,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
    };
  }

  /// Tasa de conversión del equipo
  double get tasaConversion => 
    totalLlamadas > 0 ? (ventasRealizadas / totalLlamadas) * 100 : 0.0;

  /// Promedio de llamadas por agente
  double get promedioLlamadasPorAgente => 
    totalAgentes > 0 ? totalLlamadas / totalAgentes : 0.0;
}
