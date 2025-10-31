/// Modelo para las métricas del agente desde el endpoint overview
/// Este modelo es específico para cuando un AGENTE consulta sus propias métricas
class KPIAgenteOverviewModel {
  final String tipoUsuario;
  final String fechaDesde;
  final String fechaHasta;
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion;

  KPIAgenteOverviewModel({
    required this.tipoUsuario,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
  });

  factory KPIAgenteOverviewModel.fromJson(Map<String, dynamic> json) {
    // Para agente, las métricas vienen directamente en el objeto
    return KPIAgenteOverviewModel(
      tipoUsuario: json['tipo_usuario']?.toString() ?? 'AGENTE',
      fechaDesde: json['fecha_desde']?.toString() ?? '',
      fechaHasta: json['fecha_hasta']?.toString() ?? '',
      totalLlamadas: (json['total_llamadas'] as num?)?.toInt() ?? 0,
      ventasRealizadas: (json['ventas_realizadas'] as num?)?.toInt() ?? 0,
      tasaConversion: (json['tasa_conversion'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_usuario': tipoUsuario,
      'fecha_desde': fechaDesde,
      'fecha_hasta': fechaHasta,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
    };
  }

  /// Getter para obtener el porcentaje de conversión formateado
  String get tasaConversionFormateada => '${tasaConversion.toStringAsFixed(1)}%';

  /// Verifica si cumple con un objetivo de tasa de conversión
  bool cumpleObjetivo(double objetivo) => tasaConversion >= objetivo;
}
