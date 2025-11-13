import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/backoffice/llamadas/llamadas_bloc.dart';
import '../../services/backoffice/api_service.dart';
import '../../constants/app_constants.dart';
import '../../config/auth_manager.dart';
import 'detalle_llamada.dart';

class VentasView extends StatefulWidget {
  const VentasView({super.key});

  @override
  State<VentasView> createState() => _VentasViewState();
}

class _VentasViewState extends State<VentasView> {
  int _currentPage = 0;
  
 @override
Widget build(BuildContext context) {
  final token = AuthManager().accessToken;

  // 📱 MediaQuery para adaptar el diseño a pantallas grandes o pequeñas
  final media = MediaQuery.of(context);
  final isTablet = media.size.width > 600;
  final isLandscape = media.orientation == Orientation.landscape;

  // 🔢 Elementos por página según el tipo de pantalla
  final int itemsPorPagina = isTablet ? 8 : 5;

  return BlocProvider(
    create: (_) => VentasBloc(ApiService(token: token))..add(CargarVentas()),
    child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Listado de llamadas",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
        centerTitle: false,
        elevation: 4,
        shadowColor: Theme.of(context).primaryColor.withAlpha(80),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 12, // ← Padding adaptativo
          vertical: isLandscape ? 8 : 12,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 🔍 Filtro de ventas
            BlocBuilder<VentasBloc, VentasState>(
              builder: (context, state) {
                String currentFilter = "Todas";
                if (state is VentasCargadas) currentFilter = state.filter;

                return AnimatedContainer(
                  duration: AppConfig.animationDuration,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withAlpha(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white.withAlpha(204)
                            : Colors.black.withAlpha(80),
                        offset: const Offset(-2, -2),
                        blurRadius: 3,
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(AppConfig.borderRadius),
                      style: Theme.of(context).textTheme.bodyMedium,
                      value: currentFilter,
                      isExpanded: true,
                      icon: Icon(Icons.filter_alt,
                          color: Theme.of(context).primaryColor),
                      items: const [
                        DropdownMenuItem(value: "Todas", child: Text("Todas")),
                        DropdownMenuItem(
                            value: "Ventas auditadas",
                            child: Text("Ventas auditadas")),
                        DropdownMenuItem(
                            value: "Ventas por auditar",
                            child: Text("Ventas por auditar")),
                        DropdownMenuItem(
                            value: "Llamadas reportadas",
                            child: Text("Llamadas reportadas")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<VentasBloc>()
                              .add(FiltrarVentas(value));
                          setState(() => _currentPage = 0);
                        }
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // 📋 Lista de ventas
            Expanded(
              child: BlocBuilder<VentasBloc, VentasState>(
                builder: (context, state) {
                  if (state is VentasCargando) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is VentasCargadas) {
                    final ventas = state.visibles;
                    if (ventas.isEmpty) {
                      return Center(
                        child: Text(
                          "No hay ventas disponibles.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    // 🔢 Cálculo de paginación dinámico
                    final totalPages =
                        (ventas.length / itemsPorPagina).ceil();
                    final startIndex = _currentPage * itemsPorPagina;
                    final endIndex = startIndex + itemsPorPagina;
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
                                borderRadius: BorderRadius.circular(
                                    AppConfig.borderRadius),
                                splashColor: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withAlpha(30),
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetalleLlamadaView(venta: venta),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: AppConfig.animationDuration,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(
                                        AppConfig.borderRadius),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.white.withAlpha(204)
                                            : Colors.black.withAlpha(76),
                                        offset: const Offset(-2, -2),
                                        blurRadius: 3,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withAlpha(20),
                                        offset: const Offset(2, 2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: const Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                                    title: Text(
                                      venta.cliente,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 14,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withAlpha(153)),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Duración: ${venta.duracion}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withAlpha(153),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // 📄 Paginación
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _currentPage > 0
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    size: 16),
                                label: const Text(""),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  disabledBackgroundColor:
                                      Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "Página ${_currentPage + 1} de $totalPages",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton.icon(
                                onPressed: _currentPage < totalPages - 1
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                icon:
                                    const Icon(Icons.arrow_forward_ios, size: 16),
                                label: const Text(""),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  disabledBackgroundColor:
                                      Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else if (state is ErrorVentas) {
                    return Center(
                      child: Text(
                        state.mensaje,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}