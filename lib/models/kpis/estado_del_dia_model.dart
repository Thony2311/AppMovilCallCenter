/// Modelo auxiliar para distribución de estados del día
class EstadoDelDiaModel {
  final String estadoValor;
  final int tiempoSegundos;
  final String tiempoFormateado;
  final double porcentaje;

  EstadoDelDiaModel({
    required this.estadoValor,
    required this.tiempoSegundos,
    required this.tiempoFormateado,
    required this.porcentaje,
  });

  factory EstadoDelDiaModel.fromJson(Map<String, dynamic> json) {
    return EstadoDelDiaModel(
      estadoValor: json['estado_valor']?.toString() ?? '',
      tiempoSegundos: (json['tiempo_segundos'] as num?)?.toInt() ?? 0,
      tiempoFormateado: json['tiempo_formateado']?.toString() ?? '00:00:00',
      porcentaje: (json['porcentaje'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estado_valor': estadoValor,
      'tiempo_segundos': tiempoSegundos,
      'tiempo_formateado': tiempoFormateado,
      'porcentaje': porcentaje,
    };
  }

  /// Verifica si es el estado DISPONIBLE
  bool get isDisponible => estadoValor.toUpperCase() == 'DISPONIBLE';

  /// Verifica si es el estado EN_LLAMADA
  bool get isEnLlamada => estadoValor.toUpperCase() == 'EN_LLAMADA';

  /// Verifica si es el estado POSTCALL
  bool get isPostcall => estadoValor.toUpperCase() == 'POSTCALL';
}
