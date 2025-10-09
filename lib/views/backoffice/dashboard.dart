import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_constants.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = {
      "Llamadas reportadas": 20,
      "Ventas auditadas": 21,
      "Ventas por auditar": 19,
    };

    final total = data.values.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
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
                      color: AppColors.secondary,
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
                    color = const Color.fromARGB(255, 21, 0, 98);
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
      ),
    );
  }
}
