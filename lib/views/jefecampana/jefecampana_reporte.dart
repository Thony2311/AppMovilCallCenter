import 'package:flutter/material.dart';
import 'equipo_detalle.dart';

class JefeCampanaReporteView extends StatefulWidget {
  const JefeCampanaReporteView({super.key});

  @override
  State<JefeCampanaReporteView> createState() => _JefeCampanaReporteViewState();
}

class _JefeCampanaReporteViewState extends State<JefeCampanaReporteView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _equipos = [
    {
      "nombre": "Equipo Alfa",
      "agentes": 8,
      "llamadasRealizadas": 320,
      "llamadasAtendidas": 280,
      "llamadasAbandonadas": 40,
      "ventas": 56,
      "tasaAbandono": 12.5,
      "rendimiento": 87.5,
    },
    {
      "nombre": "Equipo Beta", 
      "agentes": 7,
      "llamadasRealizadas": 245,
      "llamadasAtendidas": 210,
      "llamadasAbandonadas": 35,
      "ventas": 43,
      "tasaAbandono": 14.3,
      "rendimiento": 85.7,
    },
    {
      "nombre": "Equipo Gamma",
      "agentes": 9,
      "llamadasRealizadas": 295,
      "llamadasAtendidas": 255,
      "llamadasAbandonadas": 40,
      "ventas": 51,
      "tasaAbandono": 13.6,
      "rendimiento": 86.4,
    },
    {
      "nombre": "Equipo Delta",
      "agentes": 8,
      "llamadasRealizadas": 280,
      "llamadasAtendidas": 250,
      "llamadasAbandonadas": 30,
      "ventas": 62,
      "tasaAbandono": 10.7,
      "rendimiento": 89.3,
    },
  ];

  String _busqueda = "";
  bool _isLoading = false;
  int _currentPage = 0;
  final int _itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Simular carga de datos
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
  }

  /// Obtener color según rendimiento del equipo
  Color _getColorRendimiento(double rendimiento) {
    if (rendimiento >= 90) return Colors.green;
    if (rendimiento >= 80) return Colors.blue;
    if (rendimiento >= 70) return Colors.orange;
    return Colors.red;
  }

  /// Widget de card de equipo simplificado
  Widget _buildEquipoCard(BuildContext context, Map<String, dynamic> equipo, bool isSmallScreen) {
    final nombre = equipo["nombre"] as String;
    final agentes = equipo["agentes"] as int;
    final rendimiento = equipo["rendimiento"] as double;
    
    final colorRendimiento = _getColorRendimiento(rendimiento);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EquipoDetalleView(equipo: equipo),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y cantidad de agentes
              Row(
                children: [
                  // Icono del equipo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.groups,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nombre del equipo y agentes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '$agentes agentes',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Icono de flecha
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Barra de rendimiento
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rendimiento',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${rendimiento.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.bold,
                          color: colorRendimiento,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Barra de progreso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: rendimiento / 100,
                      minHeight: isSmallScreen ? 8 : 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(colorRendimiento),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget de estado vacío
  Widget _buildEmptyState(BuildContext context, bool isSmallScreen) {
    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 32 : 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: isSmallScreen ? 64 : 80,
                color: Colors.grey[400],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'No se encontraron equipos',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                'Intenta con otros términos de búsqueda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Filtrar equipos por búsqueda
    final equiposFiltrados = _equipos.where((equipo) {
      final nombre = equipo["nombre"] as String;
      return nombre.toLowerCase().contains(_busqueda.toLowerCase());
    }).toList();

    // Paginación
    final totalPages = (equiposFiltrados.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage > equiposFiltrados.length)
        ? equiposFiltrados.length
        : startIndex + _itemsPerPage;
    final equiposPaginados = equiposFiltrados.isEmpty 
        ? <Map<String, dynamic>>[]
        : equiposFiltrados.sublist(startIndex, endIndex);

    // Widget de carga
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Contenido principal
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: Column(
        children: [
          // Sección scrolleable
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              // Título
              Text(
                'Equipos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Barra de búsqueda
              TextField(
                onChanged: (value) {
                  setState(() {
                    _busqueda = value;
                    _currentPage = 0; // Resetear página al buscar
                  });
                },
                decoration: InputDecoration(
                  hintText: "Buscar equipo...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _busqueda.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _busqueda = ""),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 12 : 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Contador de equipos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${equiposFiltrados.length} equipos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                  ),
                  if (equiposFiltrados.isEmpty && _busqueda.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => setState(() => _busqueda = ""),
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Limpiar'),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista de equipos paginados
              if (equiposFiltrados.isEmpty)
                _buildEmptyState(context, isSmallScreen)
              else
                ...equiposPaginados.map((equipo) {
                  return _buildEquipoCard(context, equipo, isSmallScreen);
                }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Paginación fija en la parte inferior
          if (totalPages > 1)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildPaginationControls(context, totalPages, isSmallScreen),
            ),
        ],
      ),
    );
  }

  /// Widget de controles de paginación (fijo en la parte inferior)
  Widget _buildPaginationControls(BuildContext context, int totalPages, bool isSmallScreen) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 12 : 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón anterior
            ElevatedButton.icon(
              onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              label: Text(isSmallScreen ? '' : 'Anterior'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: 10,
                ),
              ),
            ),

            // Indicador de página
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_currentPage + 1} / $totalPages',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            // Botón siguiente
            ElevatedButton.icon(
              onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
              label: Text(isSmallScreen ? '' : 'Siguiente'),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}