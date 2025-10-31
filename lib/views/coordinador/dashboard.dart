import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/usuario_model.dart';
import '../../services/user_service.dart';
import '../../utils/app_logger.dart';

class CoordinadorDashboardView extends StatefulWidget {
  const CoordinadorDashboardView({super.key});

  @override
  State<CoordinadorDashboardView> createState() => _CoordinadorDashboardViewState();
}

class _CoordinadorDashboardViewState extends State<CoordinadorDashboardView> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Perfil del coordinador
  UsuarioModel? _perfil;
  bool _loadingPerfil = true;
  String? _errorMessage;

  // Datos mock mientras se acomoda el endpoint
  final int _totalLlamadas = 156;
  final int _totalVentas = 38;
  final int _agentesDisponibles = 8;
  final int _agentesEnLlamada = 12;

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
    
    // Cargar datos del coordinador
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    
    setState(() {
      _loadingPerfil = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('📊 Cargando perfil del coordinador...');
      
      // Cargar perfil del coordinador
      final perfil = await UserService.obtenerPerfilActual();
      
      AppLogger.info('✅ Perfil cargado: ${perfil.fullName} (${perfil.role})');
      
      if (!mounted) return;
      
      setState(() {
        _perfil = perfil;
        _loadingPerfil = false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error al cargar perfil del coordinador: $e');
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
                // Header con info del coordinador
                _buildHeaderCard(context, isSmallScreen),
                const SizedBox(height: 24),

                // Título de métricas
                Text(
                  'Resumen del Equipo',
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
                        subtitle: 'Hoy',
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
                        subtitle: 'Hoy',
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gráfico de dona - Estado de agentes
                _buildAgentesStatusCard(context, isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header con información del coordinador
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
            // Avatar del coordinador
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
            
            // Información del coordinador
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
                      Icon(Icons.badge, color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Coordinador',
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

  /// Card con gráfico de dona - Estado de agentes
  Widget _buildAgentesStatusCard(BuildContext context, bool isSmallScreen) {
    final totalAgentes = _agentesDisponibles + _agentesEnLlamada;
    
    // Manejo de caso cuando no hay agentes (división por cero)
    if (totalAgentes == 0) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: isSmallScreen ? 48 : 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No hay agentes registrados',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final porcentajeDisponibles = ((_agentesDisponibles / totalAgentes) * 100).toStringAsFixed(0);
    final porcentajeEnLlamada = ((_agentesEnLlamada / totalAgentes) * 100).toStringAsFixed(0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de Agentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Gráfico de dona y leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gráfico de dona
                SizedBox(
                  width: isSmallScreen ? 120 : 140,
                  height: isSmallScreen ? 120 : 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // CustomPaint para el gráfico de dona
                      CustomPaint(
                        size: Size(isSmallScreen ? 120 : 140, isSmallScreen ? 120 : 140),
                        painter: DonutChartPainter(
                          disponibles: _agentesDisponibles,
                          enLlamada: _agentesEnLlamada,
                        ),
                      ),
                      // Total en el centro
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            totalAgentes.toString(),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 28 : 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            'Agentes',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Leyenda
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      context,
                      'Disponibles',
                      _agentesDisponibles,
                      '$porcentajeDisponibles%',
                      Colors.green,
                      isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    _buildLegendItem(
                      context,
                      'En Llamada',
                      _agentesEnLlamada,
                      '$porcentajeEnLlamada%',
                      Colors.blue,
                      isSmallScreen,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Item de leyenda para el gráfico de dona
  Widget _buildLegendItem(
    BuildContext context,
    String label,
    int value,
    String percentage,
    Color color,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 12 : 16,
          height: isSmallScreen ? 12 : 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Row(
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '($percentage)',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Painter para el gráfico de dona
class DonutChartPainter extends CustomPainter {
  final int disponibles;
  final int enLlamada;

  DonutChartPainter({
    required this.disponibles,
    required this.enLlamada,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = size.width * 0.2; // 20% del ancho

    final total = disponibles + enLlamada;
    if (total == 0) return;

    // Colores
    const colorDisponibles = Colors.green;
    const colorEnLlamada = Colors.blue;

    // Calcular ángulos
    final angleDisponibles = (disponibles / total) * 2 * math.pi;
    final angleEnLlamada = (enLlamada / total) * 2 * math.pi;

    // Dibujar segmento de Disponibles
    final paintDisponibles = Paint()
      ..color = colorDisponibles
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Comenzar desde arriba
      angleDisponibles,
      false,
      paintDisponibles,
    );

    // Dibujar segmento de En Llamada
    final paintEnLlamada = Paint()
      ..color = colorEnLlamada
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2 + angleDisponibles, // Continuar después del primer segmento
      angleEnLlamada,
      false,
      paintEnLlamada,
    );
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return oldDelegate.disponibles != disponibles ||
        oldDelegate.enLlamada != enLlamada;
  }
}