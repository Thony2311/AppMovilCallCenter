import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'dart:math' as math;

class AgenteDashboardView extends StatefulWidget {
  const AgenteDashboardView({super.key});

  @override
  State<AgenteDashboardView> createState() => _AgenteDashboardViewState();
}

class _AgenteDashboardViewState extends State<AgenteDashboardView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _squareMetricCard(String title, String value, IconData icon, BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: AppConfig.animationDuration,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeMetricCard(String title, String timeValue, IconData icon, BuildContext context) {
    // Convertir tiempo "5:20" a minutos para el gráfico (5 minutos + 20 segundos / 60)
    final parts = timeValue.split(':');
    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);
    final totalMinutes = minutes + (seconds / 60);
    
    // Porcentaje basado en un máximo de 10 minutos
    final percentage = (totalMinutes / 10) * 100;
    
    return Expanded(
      child: AnimatedContainer(
        duration: AppConfig.animationDuration,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: TimerChartPainter(
                  percentage: percentage,
                  color:  const Color.fromARGB(255, 114, 198, 236),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Center(
                  child: Text(
                    timeValue,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qualityMetricCard(String title, double percentage, IconData icon, BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: AppConfig.animationDuration,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: PieChartPainter(
                  percentage: percentage,
                  color:  const Color.fromARGB(255, 114, 198, 236),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Center(
                  child: Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor, 
        title: Text("Dashboard", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)), 
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).scaffoldBackgroundColor), 
            onPressed: () {},
          ),
        ],
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
            Row(
              children: [
                _squareMetricCard("Llamadas atendidas hoy", "20", Icons.call, context),
                _squareMetricCard("Ventas hoy", "5", Icons.shopping_bag, context),
              ],
            ),
            Row(
              children: [
                _timeMetricCard("Promedio de tiempo", "5:20", Icons.timer, context),
                _qualityMetricCard("Calidad de servicio", 80, Icons.star, context),
              ],
            ),
          ],
        ),
      ),
    ),
    );
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
      ..color = backgroundColor.withAlpha(127)
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