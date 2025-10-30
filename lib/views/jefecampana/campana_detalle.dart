import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'package:fl_chart/fl_chart.dart';

class CampanaDetalleView extends StatefulWidget {
  final Map<String, dynamic> campana;

  const CampanaDetalleView({super.key, required this.campana});

  @override
  State<CampanaDetalleView> createState() => _CampanaDetalleViewState();
}

class _CampanaDetalleViewState extends State<CampanaDetalleView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pieAnimationController;
  late Animation<double> _pieAnimation;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation; 
  late Animation<double> _scaleAnimation; 

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  //animacion del pastel
    _pieAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pieAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pieAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    //animaciones de la grafica de barras
     _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _pieAnimationController.forward();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pieAnimationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _callDistributionPieChart(BuildContext context) {
    return AnimatedBuilder(
      animation: _pieAnimationController,
      builder: (context, child) {
       return SizedBox(
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withAlpha(10),
              ),
            ),
            // Gráfico de pastel
              PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: ((widget.campana["llamadasAtendidas"] as num?)?.toDouble() ?? 0) * _pieAnimation.value,
                      title: _pieAnimation.value > 0.5 ?
                      '${widget.campana["llamadasAtendidas"]}\nAtendidas': '',
                      radius: 50 * _pieAnimation.value,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: ((widget.campana["llamadasAbandonadas"] as num?)?.toDouble() ?? 0) * _pieAnimation.value,
                      title: _pieAnimation.value > 0.5 ?
                      '${widget.campana["llamadasAbandonadas"]}\nAbandonadas': '',
                      radius: 40 * _pieAnimation.value,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  centerSpaceRadius: 40,
                  startDegreeOffset: 270, 
                  sectionsSpace: 2, 
                ),
              ),

               if (_pieAnimation.value < 0.95)
              Text(
                "${(_pieAnimation.value * 100).toInt()}%",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
            ),
          ),
          ],
        ),
        );
      },
    );
  }

Widget _weeklyTrendChart(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Llamadas por Día - ${widget.campana["nombre"]}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
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
                                final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];
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
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: 180,
                                color: Colors.purple,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: 220,
                                color: Colors.purple,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: 190,
                                color: Colors.purple,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: 250,
                                color: Colors.purple,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          ),
                          BarChartGroupData(
                            x: 4,
                            barRods: [
                              BarChartRodData(
                                toY: 200,
                                color: Colors.purple,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          ),
                        ],
                        gridData: const FlGridData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

 Widget _buildLlamadasTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Distribución de Llamadas (Total: ${widget.campana["llamadasRealizadas"]})",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _callDistributionPieChart(context),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _legendItem("Atendidas (${widget.campana["llamadasAtendidas"]})", Colors.green),
                    _legendItem("Abandonadas (${widget.campana["llamadasAbandonadas"]})", Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.trending_down, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        "Tasa de Abandono: ${widget.campana["tasaAbandono"]}%",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
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
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildResumenTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(50), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20), 
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _weeklyTrendChart(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.campana["nombre"] as String,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.purple,
              labelColor: Colors.purple,
              unselectedLabelColor: Theme.of(context).hintColor,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              tabs: const [
                Tab(text: 'Llamadas'),
                Tab(text: 'Resumen'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLlamadasTab(context),
                _buildResumenTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}