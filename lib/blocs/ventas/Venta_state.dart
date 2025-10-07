part of 'ventas_bloc.dart';

abstract class VentasState {}

class VentasCargando extends VentasState {}

class VentasCargadas extends VentasState {
  final List<Venta> ventas;    // todas las ventas
  final String filter;       // filtro actual
  final List<Venta> visibles;  // ventas filtradas

  VentasCargadas(this.ventas, {required this.filter, List<Venta>? visible})
      : visibles = visible ?? ventas;
}

class ErrorVentas extends VentasState {
  final String mensaje;
  ErrorVentas(this.mensaje);
}
