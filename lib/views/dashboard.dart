import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(title, style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: AppTextStyles.title),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildStatCard("Llamadas reportadas", "20", Icons.report_problem),
          _buildStatCard("Ventas auditadas", "21", Icons.phone_forwarded),
          _buildStatCard("Ventas por auditar", "19", Icons.phone_in_talk),
        ],
      ),
    );
  }
}
