import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../coordinador/detalle_agente.dart';

class JefeCampanaAgentesView extends StatefulWidget {
  const JefeCampanaAgentesView({super.key});

  @override
  State<JefeCampanaAgentesView> createState() => _JefeCampanaAgentesViewState();
}

class _JefeCampanaAgentesViewState extends State<JefeCampanaAgentesView> {
  final agents = [
    {
      "nombre": "Carlos López", 
      "estado": "Conectado", 
      "llamadas": 25, // Changed to int
      "codigo": "AG001",
      "ventas": 8 // Changed to int
    },
    {
      "nombre": "María Torres", 
      "estado": "En pausa", 
      "llamadas": 10, // Changed to int
      "codigo": "AG002",
      "ventas": 3 // Changed to int
    },
    {
      "nombre": "Andrés Ríos", 
      "estado": "Desconectado", 
      "llamadas": 0, // Changed to int
      "codigo": "AG003", 
      "ventas": 0 // Changed to int
    },
    {
      "nombre": "Laura Díaz", 
      "estado": "Conectado", 
      "llamadas": 18, // Changed to int
      "codigo": "AG004",
      "ventas": 5 // Changed to int
    },
  ];

  String _busqueda = "";
  int _currentPage = 0;
  final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final agentsFiltrados = agents
        .where((agente) =>
            (agente["nombre"] as String).toLowerCase().contains(_busqueda.toLowerCase()))
        .toList();

    final totalPages = (agentsFiltrados.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final agentsPaginados = agentsFiltrados.sublist(
      startIndex,
      endIndex > agentsFiltrados.length ? agentsFiltrados.length : endIndex,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Text(
                "Agentes del Equipo",
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
                  _currentPage = 0;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Agents List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: agentsPaginados.map((agent) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleAgenteView(
                            agente: agent.map((key, value) => MapEntry(key, value.toString())),
                          ),
                        ),
                      );
                    },
                    child: _agentCard(
                      agent["nombre"] as String,
                      agent["estado"] as String,
                      agent["llamadas"] as int, // Now passing int
                      context,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Pagination
            if (agentsFiltrados.length > _itemsPerPage) ...[
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
      ),
    );
  }

  Widget _agentCard(String name, String status, int calls, BuildContext context) {
    Color statusColor;
    switch (status) {
      case "Conectado":
        statusColor = Colors.green;
        break;
      case "En pausa":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withAlpha(51),
            child: Icon(Icons.person, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  "Llamadas: $calls",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}