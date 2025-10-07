import 'package:flutter/material.dart';
import '../models/venta_model.dart';

class DetalleLlamadaView extends StatelessWidget {
  final Venta venta;

  const DetalleLlamadaView({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de la llamada"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Cliente: ${venta.cliente}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Estado: ${venta.status}"),
            const SizedBox(height: 8),
            Text("Monto: \$${venta.monto.toStringAsFixed(2)}"),
            const Divider(height: 30),
            const Text("Transcripción de la llamada", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              venta.transcripcion ?? "No hay transcripción disponible.",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

