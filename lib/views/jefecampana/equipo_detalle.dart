import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class EquipoDetalleView extends StatefulWidget {
  final Map<String, dynamic> equipo;

  const EquipoDetalleView({super.key, required this.equipo});

  @override
  State<EquipoDetalleView> createState() => _EquipoDetalleViewState();
}

class _EquipoDetalleViewState extends State<EquipoDetalleView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = false;

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

  /// Simular carga de datos
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
  }

  /// Calcular tasa de conversión
  double get _tasaConversion {
    final total = widget.equipo["llamadasRealizadas"] as int;
    if (total == 0) return 0.0;
    final ventas = widget.equipo["ventas"] as int? ?? 45; // Valor mock si no existe
    return (ventas / total) * 100;
  }

  /// Widget de gráfico de dona para distribución de llamadas vs ventas
  Widget _buildDonutChart(BuildContext context, bool isSmallScreen) {
    final total = widget.equipo["llamadasRealizadas"] as int;
    final ventas = widget.equipo["ventas"] as int? ?? 45; // Valor mock si no existe
    final llamadasSinVenta = total - ventas;
    
    final porcentajeLlamadas = ((llamadasSinVenta / total) * 100).toStringAsFixed(0);
    final porcentajeVentas = ((ventas / total) * 100).toStringAsFixed(0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gráfico de dona
        SizedBox(
          width: isSmallScreen ? 140 : 160,
          height: isSmallScreen ? 140 : 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // CustomPaint para el gráfico de dona
              CustomPaint(
                size: Size(isSmallScreen ? 140 : 160, isSmallScreen ? 140 : 160),
                painter: LlamadasDonutChartPainter(
                  llamadasSinVenta: llamadasSinVenta,
                  ventas: ventas,
                ),
              ),
              // Total en el centro
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    total.toString(),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    'Llamadas',
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
            _buildDonutLegendItem(
              context,
              'Llamadas Totales',
              llamadasSinVenta,
              '$porcentajeLlamadas%',
              Colors.blue,
              isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildDonutLegendItem(
              context,
              'Ventas',
              ventas,
              '$porcentajeVentas%',
              Colors.green,
              isSmallScreen,
            ),
          ],
        ),
      ],
    );
  }

  /// Item de leyenda para el gráfico de dona
  Widget _buildDonutLegendItem(
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

  /// Widget de gráfico de barras para tendencia semanal
  Widget _buildBarChart(BuildContext context, bool isSmallScreen) {
    // Datos mock de llamadas por día
    final llamadasPorDia = [65, 58, 72, 68, 57];
    
    return SizedBox(
      height: isSmallScreen ? 180 : 220,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
                return BarTooltipItem(
                  '${days[group.x.toInt()]}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toInt()} llamadas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(llamadasPorDia.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: llamadasPorDia[index].toDouble(),
                  color: Theme.of(context).primaryColor,
                  width: isSmallScreen ? 16 : 20,
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ],
            );
          }),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          maxY: 80,
        ),
      ),
    );
  }

  /// Tab de distribución de llamadas
  Widget _buildLlamadasTab(BuildContext context, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          // Card de distribución de llamadas vs ventas
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Llamadas Totales vs Ventas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${widget.equipo["llamadasRealizadas"]} llamadas',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gráfico de dona con leyenda
                  _buildDonutChart(context, isSmallScreen),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card de tasa de conversión
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasa de Conversión',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_tasaConversion.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.info_outline,
                    color: Colors.green,
                    size: isSmallScreen ? 24 : 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tab de tendencias con gráfico de barras
  Widget _buildResumenTab(BuildContext context, bool isSmallScreen) {
    final llamadasPorDia = [65, 58, 72, 68, 57];
    final promedioLlamadas = llamadasPorDia.reduce((a, b) => a + b) / llamadasPorDia.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          // Card de gráfico de barras
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Llamadas por Día - ${widget.equipo["nombre"]}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Última semana',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Gráfico de barras
                  _buildBarChart(context, isSmallScreen),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cards de métricas
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Total Semanal',
                  llamadasPorDia.reduce((a, b) => a + b).toString(),
                  Icons.phone_in_talk,
                  Colors.blue,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Promedio/Día',
                  promedioLlamadas.toStringAsFixed(0),
                  Icons.analytics,
                  Colors.purple,
                  isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget de card de métrica
  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Widget de carga
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.equipo["nombre"].toString()),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.equipo["nombre"].toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: Column(
          children: [
            // Tab Bar moderno
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.normal,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Distribución'),
                  Tab(text: 'Tendencias'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLlamadasTab(context, isSmallScreen),
                    _buildResumenTab(context, isSmallScreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter para el gráfico de dona de llamadas vs ventas
class LlamadasDonutChartPainter extends CustomPainter {
  final int llamadasSinVenta;
  final int ventas;

  LlamadasDonutChartPainter({
    required this.llamadasSinVenta,
    required this.ventas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = size.width * 0.2; // 20% del ancho

    final total = llamadasSinVenta + ventas;
    if (total == 0) return;

    // Colores
    const colorLlamadas = Colors.blue;
    const colorVentas = Colors.green;

    // Calcular ángulos
    final angleLlamadas = (llamadasSinVenta / total) * 2 * math.pi;
    final angleVentas = (ventas / total) * 2 * math.pi;

    // Dibujar segmento de Llamadas
    final paintLlamadas = Paint()
      ..color = colorLlamadas
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Comenzar desde arriba
      angleLlamadas,
      false,
      paintLlamadas,
    );

    // Dibujar segmento de Ventas
    final paintVentas = Paint()
      ..color = colorVentas
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2 + angleLlamadas, // Continuar después del primer segmento
      angleVentas,
      false,
      paintVentas,
    );
  }

  @override
  bool shouldRepaint(LlamadasDonutChartPainter oldDelegate) {
    return oldDelegate.llamadasSinVenta != llamadasSinVenta ||
        oldDelegate.ventas != ventas;
  }
}