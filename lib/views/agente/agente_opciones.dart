import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../login.dart';
class AgenteOpcionesView extends StatelessWidget {
  const AgenteOpcionesView({super.key});

  Widget _optionCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool notifications = true;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Opciones", style: AppTextStyles.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                const CircleAvatar(
                    radius: 28, backgroundColor: AppColors.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Juan Perez", style: AppTextStyles.subtitle),
                    Text("juan@gmail.com", style: AppTextStyles.body),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            _optionCard("Preferencias", [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tema oscuro", style: AppTextStyles.body),
                  Switch(value: false, onChanged: (_) {}),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Notificaciones y sonidos",
                      style: AppTextStyles.body),
                  Switch(value: notifications, onChanged: (_) {}),
                ],
              ),
            ]),
            _optionCard("Cuenta", [
              const Text("Soporte", style: AppTextStyles.body),
              const SizedBox(height: 8),
              const Text("Términos y condiciones", style: AppTextStyles.body),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton( 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginView()),
    (route) => false,  );
                  },
                  child: const Text("Cerrar sesión"),
                ),
              )
            ]),
          ],
        ),
      ),
    );
  }
}
