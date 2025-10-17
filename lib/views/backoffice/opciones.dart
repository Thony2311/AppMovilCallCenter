import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../config/auth_manager.dart';
import '../../config/theme_manager.dart'; 
import '../login.dart';

class OpcionesView extends StatelessWidget {
  const OpcionesView({super.key});

  @override
  Widget build(BuildContext context) {
    final authManager = AuthManager();
    final themeManager = Provider.of<ThemeManager>(context); 
    final nombre = authManager.nombre ?? 'Usuario';
    final email = authManager.email ?? 'usuario@callcenter.com';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';
    
    final isDarkMode = themeManager.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text("Opciones", style: AppTextStyles.headers),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.accent,
                child: Text(
                  inicial,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: AppTextStyles.subtitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: AppTextStyles.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (authManager.role != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          authManager.role!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // THEME TOGGLE
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: SwitchListTile(
              title: const Text("Modo Oscuro", style: AppTextStyles.subtitle),
              subtitle: Text(isDarkMode ? "Activado" : "Desactivado", style: AppTextStyles.body),
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary,
              ),
              value: isDarkMode,
              onChanged: (value) async {
                await themeManager.toggleTheme(); 
              },
            ),
          ),
          
          _buildOption("Notificaciones y sonidos", Icons.notifications, () {}),
          _buildOption("Soporte", Icons.help, () {}),
          _buildOption("Términos y condiciones", Icons.description, () {}),
          _buildOption("Cerrar sesión", Icons.logout, () {
            _showLogoutDialog(context);
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cierre de sesión'),
        content: const Text('¿Estás seguro que deseas salir de la aplicación?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Salir'),
            onPressed: () {
              AuthManager().clearSession();
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}