import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
//import '../../constants/app_constants.dart';

class AgenteKPIView extends StatelessWidget {
  const AgenteKPIView({super.key});

  Widget _barIndicator(String label, double value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium), 
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Theme.of(context).cardColor, 
          color: Theme.of(context).primaryColor, 
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
        title: Text("Reportes", style: Theme.of(context).textTheme.titleLarge), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Llamadas", style: Theme.of(context).textTheme.titleMedium), 
            const SizedBox(height: 8),
            Text("Realizadas: 150 | Atendidas: 100 | Abandonadas: 50", 
                style: Theme.of(context).textTheme.bodyMedium), 
            const SizedBox(height: 20),
            _barIndicator("Nivel de servicio", 0.8, context),
            _barIndicator("Tasa de abandono", 0.4, context),
            _barIndicator("Tiempo medio de espera", 0.6, context),
            const SizedBox(height: 20),
            Text("Número de llamadas", style: Theme.of(context).textTheme.titleMedium), 
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
                      color: Theme.of(context).primaryColor, 
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