import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ventas/ventas_bloc.dart';
import '../services/api_service.dart';
import 'detalle_llamada.dart';

class VentasView extends StatelessWidget {
  const VentasView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VentasBloc(ApiService())..add(CargarVentas()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Ventas auditadas",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // Filtro estilo mockup
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: BlocBuilder<VentasBloc, VentasState>(
                builder: (context, state) {
                  String currentFilter = "Todas";
                  if (state is VentasCargadas) currentFilter = state.filter;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F0FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.filter_list, color: Colors.blue),
                        items: const [
                          DropdownMenuItem(value: "Todas", child: Text("Todas")),
                          DropdownMenuItem(value: "Ventas auditadas", child: Text("Ventas auditadas")),
                          DropdownMenuItem(value: "Ventas", child: Text("Ventas")),
                          DropdownMenuItem(value: "Llamadas reportadas", child: Text("Llamadas reportadas")),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<VentasBloc>().add(FiltrarVentas(value));
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Lista de ventas
            Expanded(
              child: BlocBuilder<VentasBloc, VentasState>(
                builder: (context, state) {
                  if (state is VentasCargando) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is VentasCargadas) {
                    final ventas = state.visibles;
                    if (ventas.isEmpty) {
                      return const Center(child: Text("No hay ventas disponibles."));
                    }
                    return ListView.builder(
                      itemCount: ventas.length,
                      itemBuilder: (context, index) {
                        final venta = ventas[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleLlamadaView(venta: venta),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F0FA), 
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Cliente: ${venta.cliente}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Duración: ${venta.duracion}",
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is ErrorVentas) {
                    return Center(child: Text(state.mensaje));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
