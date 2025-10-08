import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/venta_model.dart';

class DetalleLlamadaView extends StatelessWidget {
  final Venta venta;

  const DetalleLlamadaView({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Detalle de la llamada", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text("Cliente: ${venta.cliente}", style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Text("Estado: ${venta.status}", style: AppTextStyles.body),
              const SizedBox(height: 8),
              Text("Monto: \$${venta.monto.toStringAsFixed(2)}", style: AppTextStyles.body),
              const Divider(height: 30),
              const Text("Transcripción de la llamada", style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Text(
                venta.transcripcion ?? "No hay transcripción disponible.",
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
