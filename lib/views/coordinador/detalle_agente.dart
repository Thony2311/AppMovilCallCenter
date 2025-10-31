import 'package:flutter/material.dart';

class DetalleAgenteView extends StatelessWidget {
  final Map<String, dynamic> agente;

  const DetalleAgenteView({super.key, required this.agente});

  /// Obtener color según estado
  Color _getColorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'DISPONIBLE':
        return Colors.green;
      case 'EN LLAMADA':
        return Colors.blue;
      case 'POSTCALL':
        return Colors.orange;
      case 'DESCONECTADO':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Obtener icono según estado
  IconData _getIconoEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'DISPONIBLE':
        return Icons.check_circle;
      case 'EN LLAMADA':
        return Icons.phone_in_talk;
      case 'POSTCALL':
        return Icons.timer;
      case 'DESCONECTADO':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  /// Obtener iniciales
  String _getInitials(String nombre) {
    final parts = nombre.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Extraer datos del agente
    final nombre = agente["nombre"] as String;
    final codigo = agente["codigo"] as String;
    final estado = agente["estado"] as String;
    final llamadas = agente["llamadas"] as int;
    final ventas = agente["ventas"] as int;
    final tiempoPromedio = agente["tiempoPromedio"] as String;
    final email = agente["email"] as String;
    
    final color = _getColorEstado(estado);
    final icono = _getIconoEstado(estado);

    // Obtener dimensiones de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          nombre,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del agente
              _buildHeaderCard(context, nombre, codigo, estado, email, color, icono, isSmallScreen),
              const SizedBox(height: 24),

              // Título de métricas
              Text(
                'Métricas de Rendimiento',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // KPIs del agente
              Row(
                children: [
                  Expanded(
                    child: _buildModernMetricCard(
                      context,
                      'Llamadas',
                      llamadas.toString(),
                      Icons.phone_in_talk,
                      Colors.blue,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: _buildModernMetricCard(
                      context,
                      'Ventas',
                      ventas.toString(),
                      Icons.shopping_bag,
                      Colors.green,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tiempo promedio
              _buildFullWidthMetricCard(
                context,
                'Tiempo Promedio',
                tiempoPromedio,
                Icons.timer,
                Colors.orange,
                isSmallScreen: isSmallScreen,
              ),

              const SizedBox(height: 24),

              // Información adicional
              _buildInfoSection(context, email, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  /// Header del agente
  Widget _buildHeaderCard(
    BuildContext context,
    String nombre,
    String codigo,
    String estado,
    String email,
    Color color,
    IconData icono,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Row(
          children: [
            // Avatar
            Hero(
              tag: 'avatar_$codigo',
              child: CircleAvatar(
                radius: isSmallScreen ? 30 : 35,
                backgroundColor: Colors.white,
                child: Text(
                  _getInitials(nombre),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    codigo,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(icono, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        estado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Indicador de estado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  /// Card moderno de métrica
  Widget _buildModernMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de métrica de ancho completo
  Widget _buildFullWidthMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sección de información adicional
  Widget _buildInfoSection(BuildContext context, String email, bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de Contacto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.email, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}