import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ventas/ventas_bloc.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';
import 'detalle_llamada.dart';

class VentasView extends StatefulWidget {
  const VentasView({super.key});

  @override
  State<VentasView> createState() => _VentasViewState();
}

class _VentasViewState extends State<VentasView> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VentasBloc(ApiService())..add(CargarVentas()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            "Ventas auditadas",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),

            // 🔹 Filtro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BlocBuilder<VentasBloc, VentasState>(
                builder: (context, state) {
                  String currentFilter = "Todas";
                  if (state is VentasCargadas) currentFilter = state.filter;

                  return AnimatedContainer(
                    duration: AppConfig.animationDuration,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.filter_alt, color: AppColors.primary),
                        items: const [
                          DropdownMenuItem(value: "Todas", child: Text("Todas")),
                          DropdownMenuItem(value: "Ventas auditadas", child: Text("Ventas auditadas")),
                          DropdownMenuItem(value: "Ventas", child: Text("Ventas")),
                          DropdownMenuItem(value: "Llamadas reportadas", child: Text("Llamadas reportadas")),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<VentasBloc>().add(FiltrarVentas(value));
                            setState(() => _currentPage = 0); // Reinicia paginación al filtrar
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Lista de ventas
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

                    // 🧩 Calcular total de páginas
                    final totalPages = (ventas.length / _itemsPerPage).ceil();
                    final startIndex = _currentPage * _itemsPerPage;
                    final endIndex = startIndex + _itemsPerPage;
                    final visibles = ventas.sublist(
                      startIndex,
                      endIndex > ventas.length ? ventas.length : endIndex,
                    );

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: visibles.length,
                            itemBuilder: (context, index) {
                              final venta = visibles[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                                splashColor: AppColors.primary.withOpacity(0.1),
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetalleLlamadaView(venta: venta),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: AppConfig.animationDuration,
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      child: const Icon(Icons.person, color: Colors.white),
                                    ),
                                    title: Text(venta.cliente, style: AppTextStyles.subtitle),
                                    subtitle: Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text("Duración: ${venta.duracion}", style: AppTextStyles.body),
                                      ],
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // 🔹 Controles de paginación
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _currentPage > 0
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                                label: const Text(""),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "Página ${_currentPage + 1} de $totalPages",
                                style: AppTextStyles.body,
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton.icon(
                                onPressed: _currentPage < totalPages - 1
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                label: const Text(""),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
