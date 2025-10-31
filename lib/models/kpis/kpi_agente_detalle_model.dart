import 'llamada_por_hora_model.dart';
import 'estado_del_dia_model.dart';

/// Modelo detallado de KPIs de un agente
class KPIAgenteDetalleModel {
  // Información del agente
  final String agenteId;
  final String agenteNombre;
  final String? agenteEmail;
  
  // Período de reporte
  final DateTime fechaDesde;
  final DateTime fechaHasta;
  
  // KPIs principales
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion; // Porcentaje 0-100
  
  // Tiempo trabajado
  final int tiempoTrabajadoSegundos;
  final String tiempoTrabajadoFormateado;
  
  // Duración de llamadas
  final double duracionPromedioSegundos;
  final String duracionPromedioFormateado;
  
  // Estado actual
  final String? estadoActual;
  
  // Series para gráficas
  final List<LlamadaPorHoraModel>? llamadasPorHora;
  final List<EstadoDelDiaModel>? estadosDelDia;

  KPIAgenteDetalleModel({
    required this.agenteId,
    required this.agenteNombre,
    this.agenteEmail,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
    required this.tiempoTrabajadoSegundos,
    required this.tiempoTrabajadoFormateado,
    required this.duracionPromedioSegundos,
    required this.duracionPromedioFormateado,
    this.estadoActual,
    this.llamadasPorHora,
    this.estadosDelDia,
  });

  factory KPIAgenteDetalleModel.fromJson(Map<String, dynamic> json) {
    return KPIAgenteDetalleModel(
      agenteId: json['agente_id']?.toString() ?? '',
      agenteNombre: json['agente_nombre']?.toString() ?? '',
      agenteEmail: json['agente_email']?.toString(),
      fechaDesde: DateTime.parse(json['fecha_desde'].toString()),
      fechaHasta: DateTime.parse(json['fecha_hasta'].toString()),
      totalLlamadas: (json['total_llamadas'] as num?)?.toInt() ?? 0,
      ventasRealizadas: (json['ventas_realizadas'] as num?)?.toInt() ?? 0,
      tasaConversion: (json['tasa_conversion'] as num?)?.toDouble() ?? 0.0,
      tiempoTrabajadoSegundos: (json['tiempo_trabajado_segundos'] as num?)?.toInt() ?? 0,
      tiempoTrabajadoFormateado: json['tiempo_trabajado_formateado']?.toString() ?? '00:00:00',
      duracionPromedioSegundos: (json['duracion_promedio_segundos'] as num?)?.toDouble() ?? 0.0,
      duracionPromedioFormateado: json['duracion_promedio_formateado']?.toString() ?? '00:00',
      estadoActual: json['estado_actual']?.toString(),
      llamadasPorHora: (json['llamadas_por_hora'] as List<dynamic>?)
          ?.map((item) => LlamadaPorHoraModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      estadosDelDia: (json['estados_del_dia'] as List<dynamic>?)
          ?.map((item) => EstadoDelDiaModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agente_id': agenteId,
      'agente_nombre': agenteNombre,
      'agente_email': agenteEmail,
      'fecha_desde': fechaDesde.toIso8601String(),
      'fecha_hasta': fechaHasta.toIso8601String(),
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
      'tiempo_trabajado_segundos': tiempoTrabajadoSegundos,
      'tiempo_trabajado_formateado': tiempoTrabajadoFormateado,
      'duracion_promedio_segundos': duracionPromedioSegundos,
      'duracion_promedio_formateado': duracionPromedioFormateado,
      'estado_actual': estadoActual,
      'llamadas_por_hora': llamadasPorHora?.map((l) => l.toJson()).toList(),
      'estados_del_dia': estadosDelDia?.map((e) => e.toJson()).toList(),
    };
  }

  /// Calcula el porcentaje de efectividad formateado
  String get efectividadPorcentaje => '${tasaConversion.toStringAsFixed(2)}%';

  /// Indica si cumple con un objetivo de conversión
  bool cumpleObjetivo(double objetivoPorcentaje) => 
    tasaConversion >= objetivoPorcentaje;

  /// Verifica si el agente está activo
  bool get isActivo => estadoActual != null && estadoActual!.toUpperCase() != 'DESCONECTADO';

  /// Promedio de llamadas por hora trabajada
  double get promedioLlamadasPorHora => 
    tiempoTrabajadoSegundos > 0 
      ? (totalLlamadas / (tiempoTrabajadoSegundos / 3600)) 
      : 0.0;
}
