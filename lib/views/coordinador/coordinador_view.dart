// Create a new file: coordinador_main_screen.dart
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import 'dashboard.dart';
import 'coordinador_equipo.dart';
import 'reporte.dart';
import 'coordinador_opciones.dart';

class CoordinadorMainScreen extends StatefulWidget {
  const CoordinadorMainScreen({super.key});

  @override
  State<CoordinadorMainScreen> createState() => _CoordinadorMainScreenState();
}

class _CoordinadorMainScreenState extends State<CoordinadorMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CoordinadorDashboardView(),
    const CoordinadorEquipoView(),
    const CoordinadorReporteView(),
    const CoordinadorOpcionesView(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Mi Equipo", 
    "Reportes",
    "Opciones",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: AnimatedSwitcher(
        duration: AppConfig.animationDuration,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Equipo"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Reportes"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Opciones"),
        ],
      ),
    );
  }
}