part of 'ventas_bloc.dart';

abstract class VentasEvent {}

class CargarVentas extends VentasEvent {}

class FiltrarVentas extends VentasEvent {
  final String filter;
  FiltrarVentas(this.filter);
}
