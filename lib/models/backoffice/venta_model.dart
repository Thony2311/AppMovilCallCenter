class Venta {
  final int id;
  final String cliente;
  final String producto;
  final String agente;
  final String fecha;
  final String duracion;
  final String status;
  final double monto;
  final String? transcripcion;

  Venta({
    required this.id,
    required this.cliente,
    required this.producto,
    required this.agente,
    required this.fecha,
    required this.duracion,
    required this.status,
    required this.monto,
    this.transcripcion,
  });
}
