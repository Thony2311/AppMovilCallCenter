import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class AgenteDashboardView extends StatelessWidget {
  const AgenteDashboardView({Key? key}) : super(key: key);

  Widget _metricCard(String title, String value, IconData icon) {
    return AnimatedContainer(
      duration: AppConfig.animationDuration,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 32),
        title: Text(title, style: AppTextStyles.subtitle),
        subtitle: Text(value,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Dashboard", style: AppTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _metricCard("Llamadas atendidas hoy", "20", Icons.call),
            _metricCard("Tiempo promedio de llamada", "5:20", Icons.timer),
            _metricCard("Calidad de servicio", "80%", Icons.star),
            _metricCard("Ventas hoy", "5", Icons.shopping_bag),
          ],
        ),
      ),
    );
  }
}
