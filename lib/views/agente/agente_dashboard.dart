import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/estados/estados_bloc.dart';
import '../../blocs/estados/estados_event.dart';
import '../../blocs/estados/estados_state.dart';
import '../../models/usuario_model.dart';
import '../../models/kpis/estado_del_dia_model.dart';
import '../../services/user_service.dart';
import '../../services/kpis/kpis_service.dart';
import '../../utils/app_logger.dart';
import 'dart:math' as math;

class AgenteDashboardView extends StatefulWidget {
  const AgenteDashboardView({super.key});

  @override
  State<AgenteDashboardView> createState() => _AgenteDashboardViewState();
}

class _AgenteDashboardViewState extends State<AgenteDashboardView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late EstadosBloc _estadosBloc;
  
  UsuarioModel? _perfil;
  bool _loadingPerfil = true;
  String? _errorMessage;
  
  // Métricas del agente
  int _totalLlamadas = 0;
  int _ventasRealizadas = 0;
  double _tasaConversion = 0.0;
  bool _loadingMetricas = false;

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
    
    // Inicializar BLoC de estados
    _estadosBloc = EstadosBloc();
    
    // Cargar datos
    _cargarDatos();
  }

  Future<void> _cargarMetricas() async {
    if (!mounted) return;
    
    setState(() {
      _loadingMetricas = true;
    });

    try {
      AppLogger.info('📊 Obteniendo métricas del agente...');
      
      // Llamar al servicio para obtener las métricas (usa hoy por defecto)
      final metricas = await KPIsService.obtenerMetricasAgente();
      
      AppLogger.info('✅ Métricas obtenidas: ${metricas.totalLlamadas} llamadas, ${metricas.ventasRealizadas} ventas');
      
      if (!mounted) return;
      
      setState(() {
        _totalLlamadas = metricas.totalLlamadas;
        _ventasRealizadas = metricas.ventasRealizadas;
        _tasaConversion = metricas.tasaConversion;
        _loadingMetricas = false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error al cargar métricas: $e');
      AppLogger.error('StackTrace: $stackTrace');
      
      if (!mounted) return;
      
      setState(() {
        _loadingMetricas = false;
      });
      
      // No lanzar error, solo log - las métricas quedarán en 0
    }
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    
    setState(() {
      _loadingPerfil = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('=== Iniciando carga de dashboard ===');
      AppLogger.info('Cargando perfil del agente...');
      
      // Cargar perfil del agente
      final perfil = await UserService.obtenerPerfilActual();
      
      AppLogger.info('✅ Perfil cargado exitosamente: ${perfil.fullName} (${perfil.documentoId})');
      
      if (!mounted) return;
      
      setState(() {
        _perfil = perfil;
        _loadingPerfil = false;
      });

      // Cargar métricas del agente usando overview (sin restricciones de rol)
      AppLogger.info('Cargando métricas del agente (overview)...');
      _cargarMetricas();

      // Cargar estado actual
      AppLogger.info('Cargando estado actual del agente...');
      _estadosBloc.add(const LoadEstadoActual());
      
      AppLogger.info('=== Dashboard cargado exitosamente ===');
    } catch (e, stackTrace) {
      AppLogger.error('❌ ERROR al cargar datos del dashboard: $e');
      AppLogger.error('StackTrace: $stackTrace');
      
      if (!mounted) return;
      
      // Mensajes de error más específicos
      String errorMsg;
      if (e.toString().contains('401') || e.toString().contains('No autenticado')) {
        errorMsg = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
      } else if (e.toString().contains('HTML') || e.toString().contains('DOCTYPE')) {
        errorMsg = 'Error de configuración del servidor.\n\n'
            '⚠️ El backend está devolviendo HTML en lugar de JSON.\n\n'
            'Posibles causas:\n'
            '• URL del backend incorrecta\n'
            '• El endpoint /api/users/me/ no existe\n'
            '• Ngrok requiere autenticación\n'
            '• Backend no está corriendo\n\n'
            'Verifica la configuración en api_config.dart';
      } else if (e.toString().contains('Connection')) {
        errorMsg = 'No se puede conectar al servidor.\n\n'
            'Verifica:\n'
            '• Tu conexión a Internet\n'
            '• Que el backend esté corriendo\n'
            '• La URL en api_config.dart';
      } else {
        errorMsg = 'Error al cargar datos:\n\n${e.toString()}';
      }
      
      setState(() {
        _loadingPerfil = false;
        _errorMessage = errorMsg;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _estadosBloc.stopAutoRefresh();
    _estadosBloc.close();
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
    return BlocProvider.value(
      value: _estadosBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            "Mi Dashboard",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _cargarDatos,
              tooltip: 'Actualizar',
            ),
          ],
        ),
        body: _loadingPerfil
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
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
              )
            : RefreshIndicator(
                onRefresh: _cargarDatos,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header con info del agente
                          _buildHeaderCard(context),
                          const SizedBox(height: 16),

                          // Estado actual en tiempo real
                          _buildEstadoActualCard(context),
                          const SizedBox(height: 24),

                          // Título de métricas
                          Text(
                            'Mis Métricas de Hoy',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // KPIs del agente
                          _buildKPIsSection(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  /// Header con información del agente
  Widget _buildHeaderCard(BuildContext context) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar del agente
                Hero(
                  tag: 'avatar_${_perfil!.documentoId}',
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: _perfil!.fotoPerfil != null
                        ? NetworkImage(_perfil!.fotoPerfil!)
                        : null,
                    child: _perfil!.fotoPerfil == null
                        ? Text(
                            _getInitials(_perfil!),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información del agente
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _perfil!.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.badge, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _perfil!.role,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card del estado actual en tiempo real
  Widget _buildEstadoActualCard(BuildContext context) {
    return BlocBuilder<EstadosBloc, EstadosState>(
      builder: (context, state) {
        if (state is EstadoActualLoaded) {
          final estado = state.estadoActual;
          final color = _getColorEstado(estado.estadoValor);

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
              ),
              child: Row(
                children: [
                  // Indicador de estado animado
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.2),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                      Icon(
                        _getIconoEstado(estado.estadoValor),
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado Actual',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          estado.estadoValor.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tiempo en estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.timer, color: color, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          estado.tiempoEnEstadoFormateado,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is EstadosLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Sección de KPIs del agente
  Widget _buildKPIsSection(BuildContext context) {
    if (_loadingMetricas) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        // Fila 1: Llamadas y Ventas
        Row(
          children: [
            Expanded(
              child: _buildModernMetricCard(
                context,
                'Llamadas',
                _totalLlamadas.toString(),
                Icons.phone_in_talk,
                Colors.blue,
                subtitle: 'Total del día',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernMetricCard(
                context,
                'Ventas Realizadas',
                _ventasRealizadas.toString(),
                Icons.shopping_bag,
                Colors.green,
                subtitle: 'Total del día',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Tasa de conversión (si quieres mostrarlo)
        if (_tasaConversion > 0)
          _buildFullWidthMetricCard(
            context,
            'Tasa de Conversión',
            '${_tasaConversion.toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.orange,
            subtitle: _tasaConversion >= 20.0 ? '¡Excelente!' : 'Sigue así',
          ),
      ],
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
    bool isPercentage = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                if (isPercentage)
                  Icon(
                    Icons.arrow_upward,
                    color: color,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
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

  /// Card de métrica de ancho completo
  Widget _buildFullWidthMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
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
          ],
        ),
      ),
    );
  }

  /// Distribución de estados del día
  Widget _buildEstadosDistribucion(BuildContext context, List<dynamic> estados) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución del Tiempo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...estados.map((estadoDynamic) {
              // Verificar si ya es EstadoDelDiaModel o convertir desde dynamic
              final estado = estadoDynamic is EstadoDelDiaModel 
                  ? estadoDynamic
                  : EstadoDelDiaModel.fromJson(estadoDynamic as Map<String, dynamic>);
              
              final estadoValor = estado.estadoValor;
              final porcentaje = estado.porcentaje;
              final tiempo = estado.tiempoFormateado;
              final color = _getColorEstado(estadoValor);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              estadoValor.replaceAll('_', ' '),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$tiempo (${porcentaje.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: porcentaje / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'DISPONIBLE':
        return Colors.green;
      case 'EN_LLAMADA':
        return Colors.blue;
      case 'POSTCALL':
        return Colors.orange;
      case 'DESCONECTADO':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  IconData _getIconoEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'DISPONIBLE':
        return Icons.check_circle;
      case 'EN_LLAMADA':
        return Icons.phone_in_talk;
      case 'POSTCALL':
        return Icons.timer;
      case 'DESCONECTADO':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

class TimerChartPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  TimerChartPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 8.0;

    // Dibujar el círculo de fondo
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Dibujar el arco del tiempo (en sentido horario como un reloj)
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Comenzar desde arriba (12 en punto)
      sweepAngle,
      false,
      progressPaint,
    );

    // Dibujar marcas de reloj (opcional, para dar efecto de cronómetro)
    final tickPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6) - math.pi / 2;
      final startX = center.dx + (radius - strokeWidth - 2) * math.cos(angle);
      final startY = center.dy + (radius - strokeWidth - 2) * math.sin(angle);
      final endX = center.dx + (radius - strokeWidth - 6) * math.cos(angle);
      final endY = center.dy + (radius - strokeWidth - 6) * math.sin(angle);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(TimerChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class PieChartPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  PieChartPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 8.0;

    // Dibujar el círculo de fondo
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Dibujar el arco del porcentaje
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Comenzar desde arriba
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}