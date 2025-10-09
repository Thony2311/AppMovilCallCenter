import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../login.dart';
class OpcionesView extends StatelessWidget {
  const OpcionesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Opciones", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: AppColors.accent, child: const Text("J")),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Juan Perez", style: AppTextStyles.subtitle),
                  Text("juan@gmail.com", style: AppTextStyles.body),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildOption("Tema", Icons.brightness_6),
          _buildOption("Notificaciones y sonidos", Icons.notifications),
          _buildOption("Soporte", Icons.help),
          _buildOption("Términos y condiciones", Icons.description),
          _buildOption("Cerrar sesión", Icons.logout, () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginView()),
              (route) => false,
            );  
          }),
        ],
      ),
    );
  }

  Widget _buildOption(String title, IconData icon, [VoidCallback? onTap]) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
