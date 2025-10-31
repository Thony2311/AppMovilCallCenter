import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class CoordinadorReporteView extends StatefulWidget {
  const CoordinadorReporteView({super.key});

  @override
  State<CoordinadorReporteView> createState() => _CoordinadorReporteViewState();
}

class _CoordinadorReporteViewState extends State<CoordinadorReporteView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Datos mock mientras se acomoda el endpoint
  final int _totalLlamadas = 150;
  final int _llamadasAtendidas = 100;
  final int _llamadasAbandonadas = 50;
  final List<int> _llamadasPorDia = [32, 28, 35, 30, 25];
  
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

  /// Calcular tasa de abandono
  double get _tasaAbandono {
    if (_totalLlamadas == 0) return 0.0;
    return (_llamadasAbandonadas / _totalLlamadas) * 100;
  }

  /// Calcular promedio de llamadas por día
  double get _promedioLlamadas {
    if (_llamadasPorDia.isEmpty) return 0.0;
    return _llamadasPorDia.reduce((a, b) => a + b) / _llamadasPorDia.length;
  }

  /// Widget de gráfico de dona para distribución de llamadas
  Widget _buildDonutChart(BuildContext context, bool isSmallScreen) {
    final porcentajeAtendidas = ((_llamadasAtendidas / _totalLlamadas) * 100).toStringAsFixed(0);
    final porcentajeAbandonadas = ((_llamadasAbandonadas / _totalLlamadas) * 100).toStringAsFixed(0);

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
                  atendidas: _llamadasAtendidas,
                  abandonadas: _llamadasAbandonadas,
                ),
              ),
              // Total en el centro
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _totalLlamadas.toString(),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 32 : 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    'Llamadas',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
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
              'Atendidas',
              _llamadasAtendidas,
              '$porcentajeAtendidas%',
              Colors.green,
              isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildDonutLegendItem(
              context,
              'Abandonadas',
              _llamadasAbandonadas,
              '$porcentajeAbandonadas%',
              Colors.orange,
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
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey[600],
                      ),
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
          barGroups: List.generate(_llamadasPorDia.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _llamadasPorDia[index].toDouble(),
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
          maxY: 40,
        ),
      ),
    );
  }

  /// Tab de resumen con distribución de llamadas
  Widget _buildSummaryTab(BuildContext context, bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Card de distribución de llamadas
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribución de Llamadas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: $_totalLlamadas llamadas',
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
          
          // Card de tasa de abandono
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.orange.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_down,
                      color: Colors.orange,
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasa de Abandono',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_tasaAbandono.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _tasaAbandono > 30 ? Icons.warning : Icons.check_circle,
                    color: _tasaAbandono > 30 ? Colors.red : Colors.green,
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
  Widget _buildTrendsTab(BuildContext context, bool isSmallScreen) {
    return SingleChildScrollView(
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
                    'Llamadas por Día',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Últimos 5 días',
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
                  _llamadasPorDia.reduce((a, b) => a + b).toString(),
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
                  _promedioLlamadas.toStringAsFixed(0),
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
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Bar moderno
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
                  Tab(
                    icon: Icon(Icons.pie_chart, size: 20),
                    text: 'Resumen',
                  ),
                  Tab(
                    icon: Icon(Icons.show_chart, size: 20),
                    text: 'Tendencias',
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
                  _buildSummaryTab(context, isSmallScreen),
                  _buildTrendsTab(context, isSmallScreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter para el gráfico de dona de llamadas
class LlamadasDonutChartPainter extends CustomPainter {
  final int atendidas;
  final int abandonadas;

  LlamadasDonutChartPainter({
    required this.atendidas,
    required this.abandonadas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = size.width * 0.2; // 20% del ancho

    final total = atendidas + abandonadas;
    if (total == 0) return;

    // Colores
    const colorAtendidas = Colors.green;
    const colorAbandonadas = Colors.orange;

    // Calcular ángulos
    final angleAtendidas = (atendidas / total) * 2 * math.pi;
    final angleAbandonadas = (abandonadas / total) * 2 * math.pi;

    // Dibujar segmento de Atendidas
    final paintAtendidas = Paint()
      ..color = colorAtendidas
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Comenzar desde arriba
      angleAtendidas,
      false,
      paintAtendidas,
    );

    // Dibujar segmento de Abandonadas
    final paintAbandonadas = Paint()
      ..color = colorAbandonadas
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2 + angleAtendidas, // Continuar después del primer segmento
      angleAbandonadas,
      false,
      paintAbandonadas,
    );
  }

  @override
  bool shouldRepaint(LlamadasDonutChartPainter oldDelegate) {
    return oldDelegate.atendidas != atendidas ||
        oldDelegate.abandonadas != abandonadas;
  }
}