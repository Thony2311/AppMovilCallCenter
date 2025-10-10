import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/backoffice/venta_model.dart';
import '../../../services/backoffice/api_service.dart';

part 'Llamada_event.dart';
part 'Llamada_state.dart';

class VentasBloc extends Bloc<VentasEvent, VentasState> {
  final ApiService apiService;

  VentasBloc(this.apiService) : super(VentasCargando()) {
    on<CargarVentas>((event, emit) async {
      emit(VentasCargando());
      try {
        final ventas = await apiService.fetchSales();
        emit(VentasCargadas(ventas, filter: "Todas"));
      } catch (e) {
        emit(ErrorVentas("Error cargando ventas"));
      }
    });

    on<FiltrarVentas>((event, emit) async {
      if (state is VentasCargadas) {
        final current = (state as VentasCargadas);
        final filtered = event.filter == "Todas"
            ? current.ventas
            : current.ventas.where((s) {
                if (event.filter == "Ventas auditadas") {
                  return s.status == "auditada";
                } else if (event.filter == "Llamadas reportadas") {
                  return s.status == "reportada";
                } else if (event.filter == "Ventas") {
                  return s.status == "pendiente";
                }
                return true;
              }).toList();
        emit(VentasCargadas(current.ventas, filter: event.filter, visible: filtered));
      }
    });
  }
}
