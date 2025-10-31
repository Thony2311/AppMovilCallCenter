import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../services/user_service.dart';
import '../../utils/app_logger.dart';

class JefeCampanaDashboardView extends StatefulWidget {
  const JefeCampanaDashboardView({super.key});

  @override
  State<JefeCampanaDashboardView> createState() => _JefeCampanaDashboardViewState();
}

class _JefeCampanaDashboardViewState extends State<JefeCampanaDashboardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Perfil del jefe de campaña
  UsuarioModel? _perfil;
  bool _loadingPerfil = true;
  String? _errorMessage;

  // Datos mock mientras se acomoda el endpoint
  final int _totalLlamadas = 1250;
  final int _totalVentas = 285;
  final int _numeroEquipos = 4;
  final int _numeroAgentes = 32;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Cargar datos del jefe de campaña
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;

    setState(() {
      _loadingPerfil = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('📊 Cargando perfil del jefe de campaña...');

      // Cargar perfil del jefe de campaña
      final perfil = await UserService.obtenerPerfilActual();

      AppLogger.info('✅ Perfil cargado: ${perfil.fullName} (${perfil.role})');

      if (!mounted) return;

      setState(() {
        _perfil = perfil;
        _loadingPerfil = false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error al cargar perfil del jefe de campaña: $e');
      AppLogger.error('StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _loadingPerfil = false;
        _errorMessage = 'Error al cargar datos:\n${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Obtener iniciales del usuario
  String _getInitials(UsuarioModel usuario) {
    if (usuario.firstName.isNotEmpty && usuario.lastName.isNotEmpty) {
      return '${usuario.firstName[0]}${usuario.lastName[0]}'.toUpperCase();
    } else if (usuario.fullName.isNotEmpty) {
      final parts = usuario.fullName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return usuario.fullName[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de la pantalla para diseño responsivo
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Widget de carga
    if (_loadingPerfil) {
      return const Center(child: CircularProgressIndicator());
    }

    // Widget de error
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargarDatos,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Contenido principal
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con info del jefe de campaña
                _buildHeaderCard(context, isSmallScreen),
                const SizedBox(height: 24),

                // Título de métricas
                Text(
                  'Resumen de la Campaña',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // KPIs de llamadas y ventas
                Row(
                  children: [
                    Expanded(
                      child: _buildModernMetricCard(
                        context,
                        'Total Llamadas',
                        _totalLlamadas.toString(),
                        Icons.phone_in_talk,
                        Colors.blue,
                        subtitle: 'Esta semana',
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: _buildModernMetricCard(
                        context,
                        'Total Ventas',
                        _totalVentas.toString(),
                        Icons.shopping_bag,
                        Colors.green,
                        subtitle: 'Esta semana',
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // KPIs de equipos y agentes
                Row(
                  children: [
                    Expanded(
                      child: _buildModernMetricCard(
                        context,
                        'Equipos',
                        _numeroEquipos.toString(),
                        Icons.groups,
                        Colors.purple,
                        subtitle: 'Activos',
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: _buildModernMetricCard(
                        context,
                        'Agentes',
                        _numeroAgentes.toString(),
                        Icons.people,
                        Colors.orange,
                        subtitle: 'Total',
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header con información del jefe de campaña
  Widget _buildHeaderCard(BuildContext context, bool isSmallScreen) {
    if (_perfil == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(
                'Cargando perfil...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Row(
          children: [
            // Avatar del jefe de campaña
            Hero(
              tag: 'avatar_${_perfil!.documentoId}',
              child: CircleAvatar(
                radius: isSmallScreen ? 30 : 35,
                backgroundColor: Colors.white,
                backgroundImage: _perfil!.fotoPerfil != null
                    ? NetworkImage(_perfil!.fotoPerfil!)
                    : null,
                child: _perfil!.fotoPerfil == null
                    ? Text(
                        _getInitials(_perfil!),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),

            // Información del jefe de campaña
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _perfil!.fullName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.military_tech, color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Jefe de Campaña',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card moderno de métrica
  Widget _buildModernMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}