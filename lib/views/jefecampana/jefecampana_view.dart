import 'package:call_center_application/views/jefecampana/jefecampana_opciones.dart';
import 'package:call_center_application/views/jefecampana/jefecampana_reporte.dart';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'jefecampana_dashboard.dart';
import 'jefecampana_agentes.dart';
//import '../backoffice/reportes.dart'; // si ya lo tienes hecho

class JefeCampanaView extends StatefulWidget {
  const JefeCampanaView({super.key});

  @override
  State<JefeCampanaView> createState() => _JefeCampanaViewState();
}

class _JefeCampanaViewState extends State<JefeCampanaView> {
  int _selectedIndex = 0;

  final List<Widget> _views = const [
    JefeCampanaDashboardView(),
    JefeCampanaAgentesView(),
    JefeCampanaReporteView(),
    JefecampanaOpciones(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppConfig.animationDuration,
        child: _views[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).hintColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: "Agentes"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reportes"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Opciones"),
        ],
      ),
    );
  }
}
