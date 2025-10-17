import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';
import '../../blocs/backoffice/dashboard_bloc.dart';
import '../../services/backoffice/dashboard_service.dart';
import '../../config/auth_manager.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final token = AuthManager().token;

    return BlocProvider(
      create: (_) =>
          DashboardBloc(DashboardService(token: token))..add(CargarDashboard()),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor, 
        title: Text("Dashboard", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
        centerTitle: false,
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: state is DashboardCargando
                    ? null
                    : () {
                        context.read<DashboardBloc>().add(RefrescarDashboard());
                      },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardCargando) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardError) {
            return _errorView(context, state.mensaje);
          } else if (state is DashboardCargado) {
            return _buildDashboard(context, state.stats);
          }

          return Center(child: Text("Cargando datos...", style: Theme.of(context).textTheme.bodyMedium));
        },
      ),
    );
  }

  Widget _errorView(BuildContext context, String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(mensaje, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DashboardBloc>().add(CargarDashboard());
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor, 
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardStats stats) {
    final data = {
      "Llamadas reportadas": stats.llamadasReportadas,
      "Ventas auditadas": stats.ventasAuditadas,
      "Ventas por auditar": stats.ventasPorAuditar,
    };

    final total = data.values.reduce((a, b) => a + b);
    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Theme.of(context).textTheme.bodyMedium?.color), 
            const SizedBox(height: 12),
            Text("No hay datos disponibles", style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: AppConfig.animationDuration,
      child: Padding(
        key: ValueKey(total),
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // For web, use a more responsive layout
            final bool isWideScreen = constraints.maxWidth > 600;
            
            if (isWideScreen) {
              // Wide screen layout (web/tablet)
              return _buildWideLayout(context, data, total);
            } else {
              // Mobile layout
              return _buildMobileLayout(context, data, total);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Map<String, int> data, int total) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          _buildHeaderSection(context, total),
          const SizedBox(height: 24),
          
          // Chart Section - Fixed height for mobile
          SizedBox(
            height: 300, // Fixed height to prevent overflow
            child: _buildChartSection(data, total),
          ),
          
          // Legend Section
          const SizedBox(height: 24),
          _buildLegendSection(context, data),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, Map<String, int> data, int total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Chart
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHeaderSection(context, total),
              const SizedBox(height: 24),
              Expanded(
                child: _buildChartSection(data, total),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Right side - Legend
        Expanded(
          flex: 1,
          child: _buildLegendSection(context, data),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Resumen General",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            "Total de actividades: $total",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(178),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(Map<String, int> data, int total) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: PieChart(
            PieChartData(
              startDegreeOffset: 180,
              borderData: FlBorderData(show: false),
              centerSpaceRadius: 40, // Reduced for better fit
              sectionsSpace: 3,
              sections: _buildChartSections(data, total),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildChartSections(Map<String, int> data, int total) {
  return [
    _buildChartSectionData(
      value: data["Llamadas reportadas"]!.toDouble(),
      percentage: (data["Llamadas reportadas"]! / total) * 100,
      color: AppColors.reportadas,
      title: "Reportadas",
      badgeOffset: 0.85, 
    ),
    _buildChartSectionData(
      value: data["Ventas auditadas"]!.toDouble(),
      percentage: (data["Ventas auditadas"]! / total) * 100,
      color: AppColors.auditadas,
      title: "Auditadas",
      badgeOffset: 0.95, 
    ),
    _buildChartSectionData(
      value: data["Ventas por auditar"]!.toDouble(),
      percentage: (data["Ventas por auditar"]! / total) * 100,
      color: AppColors.pendientes,
      title: "Pendientes",
      badgeOffset: 0.85, 
    ),
  ];
}

PieChartSectionData _buildChartSectionData({
  required double value,
  required double percentage,
  required Color color,
  required String title,
  required double badgeOffset, 
}) {
  return PieChartSectionData(
    color: color,
    value: value,
    title: "${percentage.toStringAsFixed(1)}%",
    radius: 60,
    titleStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 12,
      shadows: [Shadow(color: Colors.black.withAlpha(64), blurRadius: 3)],
    ),
    badgeWidget: _buildChartBadge(title, color),
    badgePositionPercentageOffset: badgeOffset, 
  );
}

  Widget _buildChartBadge(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(230), 
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9, // Smaller font for badges
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegendSection(BuildContext context, Map<String, int> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Desglose por categoría",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 12),
          ...data.entries.map((e) => _buildLegendItem(context, e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, int value) {
    Color getItemColor() {
      switch (label) {
        case "Llamadas reportadas":
          return AppColors.reportadas;
        case "Ventas auditadas":
          return AppColors.auditadas;
        case "Ventas por auditar":
          return AppColors.pendientes;
        default:
          return Theme.of(context).primaryColor;
      }
    }

    final color = getItemColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withAlpha(25), 
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        border: Border.all(color: color.withAlpha(80)), 
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(100), 
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(20), 
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}