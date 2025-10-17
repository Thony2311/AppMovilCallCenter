import 'package:flutter/material.dart';
//import '../../constants/app_constants.dart';
import 'agente_dashboard.dart';
import 'agente_kpi.dart';
import 'agente_opciones.dart';

class AgenteMainView extends StatefulWidget {
  const AgenteMainView({super.key});

  @override
  State<AgenteMainView> createState() => _AgenteMainViewState();
}

class _AgenteMainViewState extends State<AgenteMainView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AgenteDashboardView(),
    AgenteKPIView(),
    AgenteOpcionesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, 
        unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153), 
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Reportes"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Opciones"),
        ],
      ),
    );
  }
}