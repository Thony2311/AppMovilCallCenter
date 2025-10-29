import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class DetalleAgenteView extends StatelessWidget {
  final Map<String, String> agente;

  const DetalleAgenteView({super.key, required this.agente});

  Widget _metricCard(String titulo, String valor, IconData icon, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo, 
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          agente["nombre"] ?? "Detalle del Agente", 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)
        ),
      ),
      body: Container(
        // Main background
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              // Content container with lighter background
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 👤 Agent Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withAlpha(51),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person, 
                            size: 40, 
                            color: Theme.of(context).primaryColor
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agente["nombre"] ?? "",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Código: ${agente["codigo"]}",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: agente["estado"] == "Activo" 
                                    ? Colors.green.withAlpha(26)
                                    : Colors.red.withAlpha(26),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: agente["estado"] == "Activo" 
                                      ? Colors.green.withAlpha(76)
                                      : Colors.red.withAlpha(76),
                                  ),
                                ),
                                child: Text(
                                  "Estado: ${agente["estado"]}",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: agente["estado"] == "Activo" 
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // 📊 Metrics Section Header
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Métricas del Agente",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 📊 Metrics Cards
                  _metricCard("Llamadas Atendidas", "120", Icons.call, context),
                  _metricCard("Ventas Realizadas", "35", Icons.shopping_bag, context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}