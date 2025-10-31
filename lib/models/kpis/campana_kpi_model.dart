import 'equipo_resumen_model.dart';

/// Modelo KPI de Campaña (para vista de jefe de campaña)
class CampanaKPIModel {
  final int campanaId;
  final String campanaNombre;
  final String estadoCampana;
  final int? objetivoLlamadas;
  final int? objetivoVentas;
  final int totalEquipos;
  final int totalAgentes;
  final int agentesDisponibles;
  final int agentesEnLlamada;
  final int agentesOtrosEstados;
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion;
  final double? progresoLlamadasPorcentaje;
  final double? progresoVentasPorcentaje;
  final List<EquipoResumenModel>? equipos;

  CampanaKPIModel({
    required this.campanaId,
    required this.campanaNombre,
    required this.estadoCampana,
    this.objetivoLlamadas,
    this.objetivoVentas,
    required this.totalEquipos,
    required this.totalAgentes,
    required this.agentesDisponibles,
    required this.agentesEnLlamada,
    required this.agentesOtrosEstados,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
    this.progresoLlamadasPorcentaje,
    this.progresoVentasPorcentaje,
    this.equipos,
  });

  factory CampanaKPIModel.fromJson(Map<String, dynamic> json) {
    return CampanaKPIModel(
      campanaId: (json['campana_id'] as num?)?.toInt() ?? 0,
      campanaNombre: json['campana_nombre']?.toString() ?? '',
      estadoCampana: json['estado_campana']?.toString() ?? '',
      objetivoLlamadas: (json['objetivo_llamadas'] as num?)?.toInt(),
      objetivoVentas: (json['objetivo_ventas'] as num?)?.toInt(),
      totalEquipos: (json['total_equipos'] as num?)?.toInt() ?? 0,
      totalAgentes: (json['total_agentes'] as num?)?.toInt() ?? 0,
      agentesDisponibles: (json['agentes_disponibles'] as num?)?.toInt() ?? 0,
      agentesEnLlamada: (json['agentes_en_llamada'] as num?)?.toInt() ?? 0,
      agentesOtrosEstados: (json['agentes_otros_estados'] as num?)?.toInt() ?? 0,
      totalLlamadas: (json['total_llamadas'] as num?)?.toInt() ?? 0,
      ventasRealizadas: (json['ventas_realizadas'] as num?)?.toInt() ?? 0,
      tasaConversion: (json['tasa_conversion'] as num?)?.toDouble() ?? 0.0,
      progresoLlamadasPorcentaje: (json['progreso_llamadas_porcentaje'] as num?)?.toDouble(),
      progresoVentasPorcentaje: (json['progreso_ventas_porcentaje'] as num?)?.toDouble(),
      equipos: (json['equipos'] as List<dynamic>?)
          ?.map((e) => EquipoResumenModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campana_id': campanaId,
      'campana_nombre': campanaNombre,
      'estado_campana': estadoCampana,
      'objetivo_llamadas': objetivoLlamadas,
      'objetivo_ventas': objetivoVentas,
      'total_equipos': totalEquipos,
      'total_agentes': totalAgentes,
      'agentes_disponibles': agentesDisponibles,
      'agentes_en_llamada': agentesEnLlamada,
      'agentes_otros_estados': agentesOtrosEstados,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
      'progreso_llamadas_porcentaje': progresoLlamadasPorcentaje,
      'progreso_ventas_porcentaje': progresoVentasPorcentaje,
      'equipos': equipos?.map((e) => e.toJson()).toList(),
    };
  }

  /// Verifica si la campaña cumple objetivo de llamadas
  bool get cumpleObjetivoLlamadas => 
    progresoLlamadasPorcentaje != null && progresoLlamadasPorcentaje! >= 100.0;

  /// Verifica si la campaña cumple objetivo de ventas
  bool get cumpleObjetivoVentas => 
    progresoVentasPorcentaje != null && progresoVentasPorcentaje! >= 100.0;

  /// Verifica si la campaña está activa
  bool get isActiva => estadoCampana.toUpperCase() == 'ACTIVA';

  /// Verifica si la campaña está pausada
  bool get isPausada => estadoCampana.toUpperCase() == 'PAUSADA';

  /// Verifica si la campaña está finalizada
  bool get isFinalizada => estadoCampana.toUpperCase() == 'FINALIZADA';
}
