import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import 'detalle_agente.dart';

class CoordinadorEquipoView extends StatefulWidget {
  const CoordinadorEquipoView({super.key});

  @override
  State<CoordinadorEquipoView> createState() => _CoordinadorEquipoViewState();
}

class _CoordinadorEquipoViewState extends State<CoordinadorEquipoView> {
  final List<Map<String, String>> _agentes = [
    {"nombre": "Carlos Gómez", "codigo": "AG001", "estado": "Activo"},
    {"nombre": "Laura Martínez", "codigo": "AG002", "estado": "Inactivo"},
    {"nombre": "Andrés Torres", "codigo": "AG003", "estado": "Activo"},
    {"nombre": "María Pérez", "codigo": "AG004", "estado": "Activo"},
    {"nombre": "Juan Rodríguez", "codigo": "AG005", "estado": "Activo"},
    {"nombre": "Ana López", "codigo": "AG006", "estado": "Inactivo"},
    {"nombre": "Pedro Sánchez", "codigo": "AG007", "estado": "Activo"},
    {"nombre": "Sofia Castro", "codigo": "AG008", "estado": "Activo"},
  ];

  String _busqueda = "";
  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final agentesFiltrados = _agentes
        .where((agente) =>
            agente["nombre"]!.toLowerCase().contains(_busqueda.toLowerCase()) ||
            agente["codigo"]!.toLowerCase().contains(_busqueda.toLowerCase()))
        .toList();

    final totalPages = (agentesFiltrados.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final agentesPaginados = agentesFiltrados.sublist(
      startIndex,
      endIndex > agentesFiltrados.length ? agentesFiltrados.length : endIndex,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              "Equipo de Agentes",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar agente...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _busqueda = value;
                _currentPage = 0; // Reset to first page when searching
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Agents List
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: agentesPaginados.map((agente) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetalleAgenteView(agente: agente)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withAlpha(51),
                        child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                      ),
                      title: Text(agente["nombre"]!, style: Theme.of(context).textTheme.bodyLarge),
                      subtitle: Text("Código: ${agente["codigo"]}"),
                      trailing: Chip(
                        label: Text(
                          agente["estado"]!,
                          style: TextStyle(
                            color: agente["estado"] == "Activo" ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                        backgroundColor: agente["estado"] == "Activo" 
                            ? Colors.green[100] 
                            : Colors.red[100],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Pagination
          if (agentesFiltrados.length > _itemsPerPage) ...[
            const SizedBox(height: 16),
            Container(
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
                      backgroundColor: Theme.of(context).primaryColor,
                      disabledBackgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    label: const Text(""),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      disabledBackgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        ],
      ),
    );
  }
}