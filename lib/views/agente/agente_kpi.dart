import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';
import '../../services/kpis/kpis_service.dart';
import '../../models/kpis/kpi_agente_metricas_model.dart';
import '../../utils/app_logger.dart';

/// Vista de KPIs para agentes del call center
/// Muestra estadísticas y métricas de desempeño de manera visual y amigable
class AgenteKPIView extends StatefulWidget {
  const AgenteKPIView({super.key});

  @override
  State<AgenteKPIView> createState() => _AgenteKPIViewState();
}

class _AgenteKPIViewState extends State<AgenteKPIView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Datos del backend
  KPIAgenteMetricasModel? _kpiData;
  bool _isLoading = true;
  String? _errorMessage;

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
    _cargarDatos();
  }

  /// Carga los datos de KPIs desde el backend
  Future<void> _cargarDatos() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('📊 Cargando KPIs del agente...');
      
      // Usar fecha de hoy para obtener métricas del día
      final ahora = DateTime.now();
      final kpiData = await KPIsService.obtenerMetricasAgenteNuevo(
        fechaDesde: ahora,
        fechaHasta: ahora,
      );
      
      AppLogger.info('✅ KPIs cargados exitosamente');
      AppLogger.info('   - Llamadas atendidas: ${kpiData.values.llamadasAtendidas}');
      AppLogger.info('   - Ventas realizadas: ${kpiData.values.ventasRealizadas}');
      AppLogger.info('   - Series datos: ${kpiData.series.llamadasPorHora.length} registros');
      
      if (!mounted) return;
      
      setState(() {
        _kpiData = kpiData;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error al cargar KPIs: $e');
      AppLogger.error('StackTrace: $stackTrace');
      
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Error al cargar datos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final width = size.width;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: const Text(
        "Reportes de Desempeño",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Actualizar datos',
          color: Colors.white,
          onPressed: () {
            _cargarDatos();
            _animationController.reset();
            _animationController.forward();
          },
        ),
      ],
    ),
    body: FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorView()
                  : _kpiData != null
                      ? _buildContentView(isDark)
                      : Center(
                          child: Text(
                            'No hay datos disponibles',
                            style: TextStyle(fontSize: width * 0.045),
                          ),
                        ),
        ),
      ),
    ),
  );
}
  /// Vista de error
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Error desconocido',
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

  /// Vista de contenido con datos del backend
  Widget _buildContentView(bool isDark) {
    final kpi = _kpiData!;
    
    // Extraer datos de values (valores actuales)
    final llamadasAtendidas = kpi.values.llamadasAtendidas;
    final ventasRealizadas = kpi.values.ventasRealizadas;
    final tiempoPromedio = kpi.values.tiempoPromedioLlamada;
    final llamadasPorHoraPromedio = kpi.values.llamadasPorHora;
    
    // Extraer metas
    final metaLlamadas = kpi.meta.llamadasAtendidas;
    final metaVentas = kpi.meta.ventasRealizadas;
    final metaTiempo = kpi.meta.tiempoPromedioLlamada;
    final metaLlamadasHora = kpi.meta.llamadasPorHora;
    
    // Series para gráfico
    final seriesLlamadas = kpi.series.llamadasPorHora;
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de indicadores de rendimiento
          _buildSectionTitle(context, "Indicadores de Rendimiento", Icons.trending_up_rounded),
          const SizedBox(height: 12),
          
          // Llamadas Atendidas
          _KPIIndicatorCard(
            label: "Llamadas Atendidas",
            value: llamadasAtendidas.toDouble(),
            target: metaLlamadas.toDouble(),
            valueText: llamadasAtendidas.toString(),
            icon: Icons.phone_in_talk,
            color: AppColors.primary,
            description: "Total de llamadas atendidas hoy",
            showAsNumber: true,
          ),
          const SizedBox(height: 12),
          
          // Llamadas por Hora (desde backend)
          _KPIIndicatorCard(
            label: "Llamadas por Hora",
            value: llamadasPorHoraPromedio,
            target: metaLlamadasHora.toDouble(),
            valueText: llamadasPorHoraPromedio.toStringAsFixed(1),
            icon: Icons.speed,
            color: Colors.purple,
            description: "Promedio de llamadas por hora trabajada",
            showAsNumber: true,
          ),
          const SizedBox(height: 12),
          
          // Ventas Realizadas
          _KPIIndicatorCard(
            label: "Ventas Realizadas",
            value: ventasRealizadas.toDouble(),
            target: metaVentas.toDouble(),
            valueText: ventasRealizadas.toString(),
            icon: Icons.shopping_bag,
            color: AppColors.success,
            description: "Total de ventas concretadas hoy",
            showAsNumber: true,
          ),
          const SizedBox(height: 12),
          
          // Tiempo Promedio de Llamada
          _KPIIndicatorCard(
            label: "Tiempo Promedio de Llamada",
            value: tiempoPromedio.toDouble(),
            target: metaTiempo.toDouble(),
            valueText: _formatearTiempo(tiempoPromedio),
            icon: Icons.timer_outlined,
            color: AppColors.accent,
            description: "Duración promedio por llamada",
            showAsNumber: true,
            isNegative: true, // Menor es mejor
          ),
          
          const SizedBox(height: 24),
          
          // Sección de gráfica de tendencias
          _buildSectionTitle(context, "Tendencia de Llamadas", Icons.analytics_rounded),
          const SizedBox(height: 12),
          _CallTrendChart(
            isDark: isDark,
            llamadasPorHora: seriesLlamadas,
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Construye el título de cada sección con un icono
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  /// Formatea segundos a formato mm:ss
  String _formatearTiempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos}m ${segs}s';
  }
}

/// Tarjeta de indicador KPI con barra de progreso
class _KPIIndicatorCard extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final String? valueText; // Texto personalizado para mostrar el valor
  final IconData icon;
  final Color color;
  final String description;
  final bool isNegative;
  final bool showAsNumber; // Si es true, muestra valor como número en vez de porcentaje

  const _KPIIndicatorCard({
    required this.label,
    required this.value,
    required this.target,
    this.valueText,
    required this.icon,
    required this.color,
    required this.description,
    this.isNegative = false,
    this.showAsNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calcular progreso normalizado (0.0 a 1.0)
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    final isOnTarget = isNegative ? value <= target : value >= target;
    
    // Texto a mostrar
    final displayText = valueText ?? (showAsNumber ? value.toStringAsFixed(0) : '${(value * 100).toStringAsFixed(0)}%');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOnTarget 
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnTarget ? Icons.check_circle : Icons.warning_rounded,
                      size: 16,
                      color: isOnTarget ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      displayText,
                      style: TextStyle(
                        color: isOnTarget ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: isDark 
                    ? Colors.grey[800]
                    : Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.7), color],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Actual: $displayText",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Meta: ${target.toStringAsFixed(0)}",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gráfica de tendencia de llamadas
class _CallTrendChart extends StatelessWidget {
  final bool isDark;
  final List<LlamadaHoraSerie>? llamadasPorHora;

  const _CallTrendChart({
    required this.isDark,
    this.llamadasPorHora,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay datos, mostrar mensaje
    if (llamadasPorHora == null || llamadasPorHora!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No hay datos de tendencia disponibles',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    // Preparar datos para el gráfico - tomar los últimos 6 valores
    final spots = <FlSpot>[];
    final labels = <String>[];
    double maxY = 5; // Valor mínimo inicial para el eje Y
    
    // Obtener los últimos 6 elementos
    final totalItems = llamadasPorHora!.length;
    final startIndex = totalItems > 6 ? totalItems - 6 : 0;
    final itemsToShow = llamadasPorHora!.sublist(startIndex);
    
    for (int i = 0; i < itemsToShow.length; i++) {
      final item = itemsToShow[i];
      
      final horaStr = item.hora; // "09:00"
      final valor = item.valor.toDouble();
      
      spots.add(FlSpot(i.toDouble(), valor));
      labels.add(horaStr); // Ya viene en formato "HH:00"
      
      if (valor > maxY) maxY = valor;
    }
    
    // Ajustar maxY para que tenga un margen
    maxY = (maxY * 1.2).ceilToDouble();
    if (maxY < 5) maxY = 5;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Llamadas por hora",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "En vivo",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 10 ? 5 : 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark 
                        ? Colors.grey[800]!
                        : Colors.grey[300]!,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[index],
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY > 10 ? 5 : 2,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.5),
                        AppColors.accent,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.accent,
                          strokeWidth: 2,
                          strokeColor: Theme.of(context).cardColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.2),
                          AppColors.accent.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}