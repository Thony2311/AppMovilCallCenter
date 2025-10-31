import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'equipo_detalle.dart';
import 'campana_detalle.dart'; // Nueva vista para detalle de campaña

class JefeCampanaReporteView extends StatefulWidget {
  const JefeCampanaReporteView({super.key});

  @override
  State<JefeCampanaReporteView> createState() => _JefeCampanaReporteViewState();
}

class _JefeCampanaReporteViewState extends State<JefeCampanaReporteView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _equipos = [
    {
      "nombre": "Equipo A",
      "agentes": 20,
      "llamadasRealizadas": 320,
      "llamadasAtendidas": 280,
      "llamadasAbandonadas": 40,
      "tasaAbandono": 12.5,
    },
    {
      "nombre": "Equipo B", 
      "agentes": 15,
      "llamadasRealizadas": 245,
      "llamadasAtendidas": 210,
      "llamadasAbandonadas": 35,
      "tasaAbandono": 14.3,
    },
    {
      "nombre": "Equipo C",
      "agentes": 18,
      "llamadasRealizadas": 295,
      "llamadasAtendidas": 255,
      "llamadasAbandonadas": 40,
      "tasaAbandono": 13.6,
    },
  ];

  final List<Map<String, dynamic>> _campanas = [
    {
      "nombre": "Campaña Ventas Q4",
      "equipos": 3,
      "llamadasRealizadas": 860,
      "llamadasAtendidas": 745,
      "llamadasAbandonadas": 115,
      "tasaAbandono": 13.4,
      "ventas": 156,
      "conversion": 18.1,
    },
    {
      "nombre": "Campaña Servicio Cliente",
      "equipos": 2,
      "llamadasRealizadas": 540,
      "llamadasAtendidas": 510,
      "llamadasAbandonadas": 30,
      "tasaAbandono": 5.6,
      "ventas": 0,
      "conversion": 0.0,
    },
    {
      "nombre": "Campaña Promocional",
      "equipos": 4,
      "llamadasRealizadas": 1200,
      "llamadasAtendidas": 980,
      "llamadasAbandonadas": 220,
      "tasaAbandono": 18.3,
      "ventas": 245,
      "conversion": 20.4,
    },
  ];

  String _busquedaEquipos = "";
  String _busquedaCampanas = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _teamCard(Map<String, dynamic> equipo, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipo["nombre"] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(
                      "${equipo["agentes"]} agentes",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${equipo["llamadasRealizadas"]}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                "llamadas",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 12),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }

  Widget _campanaCard(Map<String, dynamic> campana, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign,
              color: Colors.purple,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campana["nombre"] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.groups, size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(
                      "${campana["equipos"]} equipos",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${campana["llamadasRealizadas"]}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              Text(
                "llamadas",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 12),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEquiposTab(BuildContext context) {
    final equiposFiltrados = _equipos
        .where((equipo) =>
            (equipo["nombre"] as String).toLowerCase().contains(_busquedaEquipos.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: "Buscar equipo...",
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
              _busquedaEquipos = value;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Teams List
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: equiposFiltrados.map((equipo) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EquipoDetalleView(equipo: equipo),
                    ),
                  );
                },
                child: _teamCard(equipo, context),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCampanasTab(BuildContext context) {
    final campanasFiltradas = _campanas
        .where((campana) =>
            (campana["nombre"]as String).toLowerCase().contains(_busquedaCampanas.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: "Buscar campaña...",
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
              _busquedaCampanas = value;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Campaigns List
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: campanasFiltradas.map((campana) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CampanaDetalleView(campana: campana),
                    ),
                  );
                },
                child: _campanaCard(campana, context),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                "Reportes",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  color: Theme.of(context).primaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).hintColor,
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                tabs: const [
                  Tab(text: 'Equipos', height: 50,),
                  Tab(text: 'Campañas',height: 50,),
                ],
              ),
            ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEquiposTab(context),
                  _buildCampanasTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}