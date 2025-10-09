import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';

class AgenteKPIView extends StatelessWidget {
  const AgenteKPIView({super.key});

  Widget _barIndicator(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: AppColors.secondary,
          color: AppColors.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text("Reportes", style: AppTextStyles.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Llamadas", style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            const Text("Realizadas: 150 | Atendidas: 100 | Abandonadas: 50"),
            const SizedBox(height: 20),
            _barIndicator("Nivel de servicio", 0.8),
            _barIndicator("Tasa de abandono", 0.4),
            _barIndicator("Tiempo medio de espera", 0.6),
            const SizedBox(height: 20),
            const Text("Número de llamadas", style: AppTextStyles.subtitle),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 2),
                        const FlSpot(2, 5),
                        const FlSpot(3, 4),
                        const FlSpot(4, 6),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
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
