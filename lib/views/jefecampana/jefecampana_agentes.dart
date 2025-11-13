import 'package:flutter/material.dart';
import '../coordinador/detalle_agente.dart';

class JefeCampanaAgentesView extends StatefulWidget {
  const JefeCampanaAgentesView({super.key});

  @override
  State<JefeCampanaAgentesView> createState() => _JefeCampanaAgentesViewState();
}

class _JefeCampanaAgentesViewState extends State<JefeCampanaAgentesView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Datos mock mientras se acomoda el endpoint
  final List<Map<String, dynamic>> _agentes = [
    {
      "nombre": "Carlos López",
      "codigo": "AG001",
      "estado": "Disponible",
      "llamadas": 45,
      "ventas": 12,
      "tiempoPromedio": "5:30",
      "email": "carlos.lopez@empresa.com",
      "equipo": "Equipo Alfa"
    },
    {
      "nombre": "María Torres",
      "codigo": "AG002",
      "estado": "En Llamada",
      "llamadas": 38,
      "ventas": 9,
      "tiempoPromedio": "6:15",
      "email": "maria.torres@empresa.com",
      "equipo": "Equipo Beta"
    },
    {
      "nombre": "Andrés Ríos",
      "codigo": "AG003",
      "estado": "Postcall",
      "llamadas": 52,
      "ventas": 15,
      "tiempoPromedio": "4:45",
      "email": "andres.rios@empresa.com",
      "equipo": "Equipo Alfa"
    },
    {
      "nombre": "Laura Díaz",
      "codigo": "AG004",
      "estado": "Disponible",
      "llamadas": 41,
      "ventas": 11,
      "tiempoPromedio": "5:50",
      "email": "laura.diaz@empresa.com",
      "equipo": "Equipo Gamma"
    },
    {
      "nombre": "Juan Rodríguez",
      "codigo": "AG005",
      "estado": "En Llamada",
      "llamadas": 48,
      "ventas": 13,
      "tiempoPromedio": "5:20",
      "email": "juan.rodriguez@empresa.com",
      "equipo": "Equipo Beta"
    },
    {
      "nombre": "Ana López",
      "codigo": "AG006",
      "estado": "Desconectado",
      "llamadas": 0,
      "ventas": 0,
      "tiempoPromedio": "0:00",
      "email": "ana.lopez@empresa.com",
      "equipo": "Equipo Alfa"
    },
    {
      "nombre": "Pedro Sánchez",
      "codigo": "AG007",
      "estado": "Disponible",
      "llamadas": 43,
      "ventas": 10,
      "tiempoPromedio": "6:00",
      "email": "pedro.sanchez@empresa.com",
      "equipo": "Equipo Gamma"
    },
    {
      "nombre": "Sofia Castro",
      "codigo": "AG008",
      "estado": "En Llamada",
      "llamadas": 50,
      "ventas": 14,
      "tiempoPromedio": "5:10",
      "email": "sofia.castro@empresa.com",
      "equipo": "Equipo Delta"
    },
    {
      "nombre": "Roberto Gómez",
      "codigo": "AG009",
      "estado": "Disponible",
      "llamadas": 37,
      "ventas": 8,
      "tiempoPromedio": "6:30",
      "email": "roberto.gomez@empresa.com",
      "equipo": "Equipo Beta"
    },
    {
      "nombre": "Elena Martínez",
      "codigo": "AG010",
      "estado": "Postcall",
      "llamadas": 29,
      "ventas": 7,
      "tiempoPromedio": "5:45",
      "email": "elena.martinez@empresa.com",
      "equipo": "Equipo Delta"
    },
  ];

  String _busqueda = "";
  String _filtroEstado = "Todos";
  String _filtroEquipo = "Todos";
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

  /// Obtener lista de equipos únicos
  List<String> get _equipos {
    final equiposSet = _agentes.map((a) => a["equipo"] as String).toSet();
    return ["Todos", ...equiposSet.toList()..sort()];
  }

  /// Obtener color según estado del agente
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

  /// Obtener icono según estado del agente
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

  /// Obtener iniciales del agente
  String _getInitials(String nombre) {
    final parts = nombre.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre[0].toUpperCase();
  }

  /// Simular carga de datos
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Filtrar agentes por búsqueda, estado y equipo
    final agentesFiltrados = _agentes.where((agente) {
      final nombre = agente["nombre"] as String;
      final codigo = agente["codigo"] as String;
      final estado = agente["estado"] as String;
      final equipo = agente["equipo"] as String;

      final matchBusqueda = nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          codigo.toLowerCase().contains(_busqueda.toLowerCase());

      final matchEstado = _filtroEstado == "Todos" || estado == _filtroEstado;
      final matchEquipo = _filtroEquipo == "Todos" || equipo == _filtroEquipo;

      return matchBusqueda && matchEstado && matchEquipo;
    }).toList();

    // Paginación
    final totalPages = (agentesFiltrados.length / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage > agentesFiltrados.length)
        ? agentesFiltrados.length
        : startIndex + _itemsPerPage;
    final agentesPaginados = agentesFiltrados.isEmpty 
        ? <Map<String, dynamic>>[]
        : agentesFiltrados.sublist(startIndex, endIndex);

    // Widget de carga
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Contenido principal
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: Column(
        children: [
          // Sección de filtros (scrolleable)
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de búsqueda
                      _buildSearchBar(context, isSmallScreen),
                      const SizedBox(height: 16),

                      // Filtros de estado
                      Text(
                        'Estado',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusFilters(context, isSmallScreen),
                      const SizedBox(height: 16),

                      // Filtros de equipo
                      Text(
                        'Equipo',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildTeamFilters(context, isSmallScreen),
                      const SizedBox(height: 20),

                      // Título de la lista y botón limpiar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Agentes (${agentesFiltrados.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (agentesFiltrados.isEmpty &&
                              (_busqueda.isNotEmpty ||
                                  _filtroEstado != "Todos" ||
                                  _filtroEquipo != "Todos"))
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _busqueda = "";
                                  _filtroEstado = "Todos";
                                  _filtroEquipo = "Todos";
                                  _currentPage = 0;
                                });
                              },
                              icon: const Icon(Icons.clear, size: 18),
                              label: const Text('Limpiar'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Lista de agentes paginados
                      if (agentesFiltrados.isEmpty)
                        _buildEmptyState(context, isSmallScreen)
                      else
                        ...agentesPaginados.map((agente) {
                          return _buildAgenteCard(context, agente, isSmallScreen);
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

  /// Widget de barra de búsqueda
  Widget _buildSearchBar(BuildContext context, bool isSmallScreen) {
    return TextField(
      onChanged: (value) {
        setState(() {
          _busqueda = value;
          _currentPage = 0;
        });
      },
      decoration: InputDecoration(
        hintText: "Buscar por nombre o código...",
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
    );
  }

  /// Widget de filtros de estado
  Widget _buildStatusFilters(BuildContext context, bool isSmallScreen) {
    final estados = ["Todos", "Disponible", "En Llamada", "Postcall", "Desconectado"];

    return SizedBox(
      height: isSmallScreen ? 36 : 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: estados.length,
        itemBuilder: (context, index) {
          final estado = estados[index];
          final isSelected = _filtroEstado == estado;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                estado,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  _filtroEstado = estado;
                  _currentPage = 0;
                });
              },
              selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget de filtros de equipo
  Widget _buildTeamFilters(BuildContext context, bool isSmallScreen) {
    return SizedBox(
      height: isSmallScreen ? 36 : 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _equipos.length,
        itemBuilder: (context, index) {
          final equipo = _equipos[index];
          final isSelected = _filtroEquipo == equipo;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                equipo,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  _filtroEquipo = equipo;
                  _currentPage = 0;
                });
              },
              selectedColor: Colors.purple.withValues(alpha: 0.2),
              checkmarkColor: Colors.purple,
              side: BorderSide(
                color: isSelected ? Colors.purple : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget de card de agente
  Widget _buildAgenteCard(BuildContext context, Map<String, dynamic> agente, bool isSmallScreen) {
    final nombre = agente["nombre"] as String;
    final codigo = agente["codigo"] as String;
    final estado = agente["estado"] as String;
    final llamadas = agente["llamadas"] as int;
    final ventas = agente["ventas"] as int;
    final equipo = agente["equipo"] as String;

    final color = _getColorEstado(estado);
    final icono = _getIconoEstado(estado);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleAgenteView(agente: agente),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Hero(
                    tag: 'avatar_$codigo',
                    child: CircleAvatar(
                      radius: isSmallScreen ? 24 : 28,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      child: Text(
                        _getInitials(nombre),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 10 : 12),

                  // Información del agente
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          codigo,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Estado
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icono, color: color, size: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estado,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Métricas y equipo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$llamadas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.shopping_bag, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$ventas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.groups, size: 12, color: Colors.purple),
                        const SizedBox(width: 4),
                        Text(
                          equipo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  /// Widget de estado vacío
  Widget _buildEmptyState(BuildContext context, bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 32 : 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isSmallScreen ? 64 : 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'No se encontraron agentes',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Intenta con otros filtros o términos de búsqueda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
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