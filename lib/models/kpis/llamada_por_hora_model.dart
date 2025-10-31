/// Modelo auxiliar para gráfica de llamadas por hora
class LlamadaPorHoraModel {
  final int hora;
  final int cantidad;
  final int ventas;

  LlamadaPorHoraModel({
    required this.hora,
    required this.cantidad,
    required this.ventas,
  });

  factory LlamadaPorHoraModel.fromJson(Map<String, dynamic> json) {
    return LlamadaPorHoraModel(
      hora: (json['hora'] as num?)?.toInt() ?? 0,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      ventas: (json['ventas'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hora': hora,
      'cantidad': cantidad,
      'ventas': ventas,
    };
  }

  /// Tasa de conversión de esta hora
  double get tasaConversion => 
    cantidad > 0 ? (ventas / cantidad) * 100 : 0.0;

  /// Hora formateada (ej: "08:00")
  String get horaFormateada => '${hora.toString().padLeft(2, '0')}:00';
}
