import 'package:flutter/material.dart';

class OpcionesView extends StatelessWidget {
  const OpcionesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Opciones",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                CircleAvatar(radius: 30, child: Text("J")),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Juan Perez", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Juan@gmail.com"),
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),
            _buildOption("Tema", Icons.brightness_6),
            _buildOption("Notificaciones y sonidos", Icons.notifications),
            const SizedBox(height: 30),
            _buildOption("Soporte", Icons.help),
            _buildOption("Términos y condiciones", Icons.description),
            _buildOption("Cerrar sesión", Icons.logout),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        
      ),
    );
  }
}
