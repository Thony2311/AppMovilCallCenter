import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/backoffice/venta_model.dart';

class DetalleLlamadaView extends StatelessWidget {
  final Venta venta;

  const DetalleLlamadaView({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor, 
        title: Text(
          "Detalle de la llamada", 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)
        ),
      ),
      body: Container(
        // This is the main background that covers the entire screen
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              // This container only wraps the content and has the lighter background
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cliente: ${venta.cliente}", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text("Estado: ${venta.status}", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text("Monto: \$${venta.monto.toStringAsFixed(2)}", style: Theme.of(context).textTheme.bodyMedium),
                  const Divider(height: 30),
                  Text("Transcripción de la llamada", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    venta.transcripcion ?? "No hay transcripción disponible.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}