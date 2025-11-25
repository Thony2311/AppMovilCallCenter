import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/app_constants.dart';
import 'views/backoffice/dashboard.dart';
import 'views/backoffice/ventas.dart';
import 'views/opciones.dart';
import 'views/home.dart';
import 'views/recuperar_contrasena.dart';
import 'config/theme_manager.dart'; 

/// Punto de entrada principal de la aplicación
/// Inicializa Firebase y luego ejecuta la app
void main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase con la configuración generada
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const CallCenterApp(), 
    ),
  );
}

class CallCenterApp extends StatelessWidget {
  const CallCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return MaterialApp(
      title: 'Call Center',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeManager.themeMode,
      home: const SplashScreen(),
      routes: {
        '/recuperar': (context) => const RecuperarContrasenaView(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardView(),
    VentasView(),
    OpcionesView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Llamadas"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Opciones"),
        ],
      ),
    );
  }
}