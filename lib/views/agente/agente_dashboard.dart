import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class AgenteDashboardView extends StatelessWidget {
  const AgenteDashboardView({super.key});

  Widget _metricCard(String title, String value, IconData icon, BuildContext context) {
    return AnimatedContainer(
      duration: AppConfig.animationDuration,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 32), 
        title: Text(title, style: Theme.of(context).textTheme.titleMedium), 
        subtitle: Text(value,
            style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color 
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
        elevation: 0,
        title: Text("Dashboard", style: Theme.of(context).textTheme.titleLarge), 
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor), 
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _metricCard("Llamadas atendidas hoy", "20", Icons.call, context),
            _metricCard("Tiempo promedio de llamada", "5:20", Icons.timer, context),
            _metricCard("Calidad de servicio", "80%", Icons.star, context),
            _metricCard("Ventas hoy", "5", Icons.shopping_bag, context),
          ],
        ),
      ),
    );
  }
}