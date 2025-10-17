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
        backgroundColor: Theme.of(context).primaryColor, 
        title: Text("Opciones", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)), // 
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SizedBox(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showProfileDialog(context, nombre, email, authManager.role);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.secondary, 
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                        style: Theme.of(context).textTheme.titleMedium, 
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (authManager.role != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(51), 
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            authManager.role!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor, 
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // THEME TOGGLE
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: SwitchListTile(
              title: Text("Modo Oscuro", style: Theme.of(context).textTheme.titleMedium), 
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).primaryColor, 
              ),
              value: isDarkMode,
              onChanged: (value) async {
                await themeManager.toggleTheme(); 
              },
            ),
          ),
          
          _buildOption(context, "Notificaciones y sonidos", Icons.notifications, () {}),
          _buildOption(context, "Soporte", Icons.help, () {}),
          _buildOption(context, "Términos y condiciones", Icons.description, () {}),
          _buildOption(context, "Cerrar sesión", Icons.logout, () {
            _showLogoutDialog(context);
          }),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, IconData icon, [VoidCallback? onTap]) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.borderRadius)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor), 
        title: Text(title, style: Theme.of(context).textTheme.titleMedium), 
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color), // 
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar cierre de sesión', style: Theme.of(context).textTheme.titleMedium), 
        content: Text('¿Estás seguro que deseas salir de la aplicación?', style: Theme.of(context).textTheme.bodyMedium), // 
        actions: [
          TextButton(
            child: Text('Cancelar', style: Theme.of(context).textTheme.bodyMedium), 
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Salir', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red)), // 
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

  void _showProfileDialog(BuildContext context, String nombre, String email, String? role) {
    // Datos mockeados adicionales
    const String identificacion = 'CC-1234567890';
    const String celular = '+57 300 1234567';
    final String rolDisplay = role ?? 'Sin asignar';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Perfil',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileField(context, 'Nombre', nombre),
              _buildProfileField(context, 'Email', email),
              _buildProfileField(context, 'Identificación', identificacion),
              _buildProfileField(context, 'Celular', celular),
              _buildProfileField(context, 'Rol', rolDisplay),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cerrar', style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 45,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}