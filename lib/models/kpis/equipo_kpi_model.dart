/// Modelo KPI de Equipo (para vista de coordinador)
class EquipoKPIModel {
  final int equipoId;
  final String equipoNombre;
  final String? campanaNombre;
  final int totalAgentes;
  final int agentesDisponibles;
  final int agentesEnLlamada;
  final int agentesPostcall;
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion;
  final int tiempoPromedioLlamadaSegundos;
  final String tiempoPromedioLlamadaFormateado;

  EquipoKPIModel({
    required this.equipoId,
    required this.equipoNombre,
    this.campanaNombre,
    required this.totalAgentes,
    required this.agentesDisponibles,
    required this.agentesEnLlamada,
    required this.agentesPostcall,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
    required this.tiempoPromedioLlamadaSegundos,
    required this.tiempoPromedioLlamadaFormateado,
  });

  factory EquipoKPIModel.fromJson(Map<String, dynamic> json) {
    return EquipoKPIModel(
      equipoId: (json['equipo_id'] as num?)?.toInt() ?? 0,
      equipoNombre: json['equipo_nombre']?.toString() ?? '',
      campanaNombre: json['campana_nombre']?.toString(),
      totalAgentes: (json['total_agentes'] as num?)?.toInt() ?? 0,
      agentesDisponibles: (json['agentes_disponibles'] as num?)?.toInt() ?? 0,
      agentesEnLlamada: (json['agentes_en_llamada'] as num?)?.toInt() ?? 0,
      agentesPostcall: (json['agentes_postcall'] as num?)?.toInt() ?? 0,
      totalLlamadas: (json['total_llamadas'] as num?)?.toInt() ?? 0,
      ventasRealizadas: (json['ventas_realizadas'] as num?)?.toInt() ?? 0,
      tasaConversion: (json['tasa_conversion'] as num?)?.toDouble() ?? 0.0,
      tiempoPromedioLlamadaSegundos: (json['tiempo_promedio_llamada_segundos'] as num?)?.toInt() ?? 0,
      tiempoPromedioLlamadaFormateado: json['tiempo_promedio_llamada_formateado']?.toString() ?? '00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipo_id': equipoId,
      'equipo_nombre': equipoNombre,
      'campana_nombre': campanaNombre,
      'total_agentes': totalAgentes,
      'agentes_disponibles': agentesDisponibles,
      'agentes_en_llamada': agentesEnLlamada,
      'agentes_postcall': agentesPostcall,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
      'tiempo_promedio_llamada_segundos': tiempoPromedioLlamadaSegundos,
      'tiempo_promedio_llamada_formateado': tiempoPromedioLlamadaFormateado,
    };
  }

  /// Porcentaje de agentes disponibles
  double get porcentajeDisponibles => 
    totalAgentes > 0 ? (agentesDisponibles / totalAgentes) * 100 : 0.0;

  /// Porcentaje de agentes en llamada
  double get porcentajeEnLlamada => 
    totalAgentes > 0 ? (agentesEnLlamada / totalAgentes) * 100 : 0.0;

  /// Porcentaje de agentes en postcall
  double get porcentajePostcall => 
    totalAgentes > 0 ? (agentesPostcall / totalAgentes) * 100 : 0.0;

  /// Total de agentes ocupados (en llamada + postcall)
  int get agentesOcupados => agentesEnLlamada + agentesPostcall;
}
