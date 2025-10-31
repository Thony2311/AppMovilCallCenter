import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class JefeCampanaDashboardView extends StatelessWidget {
  const JefeCampanaDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Panel Principal",
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Tarjetas métricas
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _metricCard("Llamadas Totales", "450", Icons.phone, context),
                _metricCard("Campañas Activas", "5", Icons.campaign, context),
                _metricCard("Agentes Conectados", "23", Icons.people, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 36),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}