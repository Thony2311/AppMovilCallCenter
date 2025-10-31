/// Modelo KPI de Centro (para vista admin/backoffice)
class CentroKPIModel {
  final int centroId;
  final String centroNombre;
  final String? jefeCentroNombre;
  final int totalCampanas;
  final int totalEquipos;
  final int totalAgentes;
  final int agentesDisponibles;
  final int agentesEnLlamada;
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion;

  CentroKPIModel({
    required this.centroId,
    required this.centroNombre,
    this.jefeCentroNombre,
    required this.totalCampanas,
    required this.totalEquipos,
    required this.totalAgentes,
    required this.agentesDisponibles,
    required this.agentesEnLlamada,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
  });

  factory CentroKPIModel.fromJson(Map<String, dynamic> json) {
    return CentroKPIModel(
      centroId: (json['centro_id'] as num?)?.toInt() ?? 0,
      centroNombre: json['centro_nombre']?.toString() ?? '',
      jefeCentroNombre: json['jefe_centro_nombre']?.toString(),
      totalCampanas: (json['total_campanas'] as num?)?.toInt() ?? 0,
      totalEquipos: (json['total_equipos'] as num?)?.toInt() ?? 0,
      totalAgentes: (json['total_agentes'] as num?)?.toInt() ?? 0,
      agentesDisponibles: (json['agentes_disponibles'] as num?)?.toInt() ?? 0,
      agentesEnLlamada: (json['agentes_en_llamada'] as num?)?.toInt() ?? 0,
      totalLlamadas: (json['total_llamadas'] as num?)?.toInt() ?? 0,
      ventasRealizadas: (json['ventas_realizadas'] as num?)?.toInt() ?? 0,
      tasaConversion: (json['tasa_conversion'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centro_id': centroId,
      'centro_nombre': centroNombre,
      'jefe_centro_nombre': jefeCentroNombre,
      'total_campanas': totalCampanas,
      'total_equipos': totalEquipos,
      'total_agentes': totalAgentes,
      'agentes_disponibles': agentesDisponibles,
      'agentes_en_llamada': agentesEnLlamada,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
    };
  }

  /// Porcentaje de agentes disponibles
  double get porcentajeDisponibles => 
    totalAgentes > 0 ? (agentesDisponibles / totalAgentes) * 100 : 0.0;

  /// Porcentaje de agentes en llamada
  double get porcentajeEnLlamada => 
    totalAgentes > 0 ? (agentesEnLlamada / totalAgentes) * 100 : 0.0;

  /// Promedio de equipos por campaña
  double get promedioEquiposPorCampana => 
    totalCampanas > 0 ? totalEquipos / totalCampanas : 0.0;
}
