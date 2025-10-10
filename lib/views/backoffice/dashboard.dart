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
    // Obtener el token del AuthManager
    final token = AuthManager().token;
    
    return BlocProvider(
      create: (_) => DashboardBloc(DashboardService(token: token))
        ..add(CargarDashboard()),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Dashboard", style: AppTextStyles.headers),
        centerTitle: false,
        actions: [
          // Botón de refrescar
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is DashboardError) {
            return Center(
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
                    state.mensaje,
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DashboardBloc>().add(CargarDashboard());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reintentar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is DashboardCargado) {
            return _buildDashboardContent(context, state.stats);
          }

          return const Center(
            child: Text("Iniciando..."),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardStats stats) {
    final data = {
      "Llamadas reportadas": stats.llamadasReportadas,
      "Ventas auditadas": stats.ventasAuditadas,
      "Ventas por auditar": stats.ventasPorAuditar,
    };

    final total = data.values.reduce((a, b) => a + b);

    // Si no hay datos, mostrar mensaje
    if (total == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              "No hay datos disponibles",
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Resumen de Actividades",
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                borderData: FlBorderData(show: false),
                sections: [
                  PieChartSectionData(
                    color: AppColors.primary.withOpacity(0.9),
                    value: data["Llamadas reportadas"]!.toDouble(),
                    title:
                        "${((data["Llamadas reportadas"]! / total) * 100).toStringAsFixed(1)}%",
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppColors.accent,
                    value: data["Ventas auditadas"]!.toDouble(),
                    title:
                        "${((data["Ventas auditadas"]! / total) * 100).toStringAsFixed(1)}%",
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppColors.tertiary,
                    value: data["Ventas por auditar"]!.toDouble(),
                    title:
                        "${((data["Ventas por auditar"]! / total) * 100).toStringAsFixed(1)}%",
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          Column(
            children: data.entries.map((e) {
              Color color;
              switch (e.key) {
                case "Llamadas reportadas":
                  color = AppColors.primary.withOpacity(0.9);
                  break;
                case "Ventas auditadas":
                  color = AppColors.accent;
                  break;
                default:
                  color = AppColors.tertiary;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 18, height: 18, color: color),
                    const SizedBox(width: 8),
                    Text(
                      "${e.key} — ${e.value}",
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

