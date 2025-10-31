# Implementación del Módulo de KPIs

## 📋 Descripción General

Este módulo proporciona métricas y estadísticas en tiempo real del sistema. Incluye KPIs por agente, equipo, coordinador y vista general (overview) para diferentes roles con actualización automática cada 30 segundos.

## 📂 Estructura de Archivos Creados

### Modelos (`lib/models/kpis/`)
```
models/kpis/
├── kpi_agente_list_model.dart          # Lista simplificada de agentes
├── kpi_agente_detalle_model.dart       # KPIs detallados de un agente
├── llamada_por_hora_model.dart         # Datos para gráfica de llamadas por hora
├── estado_del_dia_model.dart           # Distribución de estados del día
├── equipo_kpi_model.dart               # KPIs de equipo (coordinador)
├── equipo_resumen_model.dart           # Resumen de equipo (jefe campaña)
├── campana_kpi_model.dart              # KPIs de campaña (jefe campaña)
├── centro_kpi_model.dart               # KPIs de centro (admin)
├── top_agente_model.dart               # Top agentes por rendimiento
└── kpi_overview_model.dart             # Vista general adaptable por rol
```

### Servicios (`lib/services/kpis/`)
```
services/kpis/
└── kpis_service.dart                   # Servicio con 4 métodos
```

### BLoCs (`lib/blocs/kpis/`)
```
blocs/kpis/
├── kpis_event.dart                     # 6 eventos
├── kpis_state.dart                     # 7 estados
└── kpis_bloc.dart                      # Lógica con polling automático
```

### Configuración
- `lib/config/api_config.dart` - Actualizado con 4 endpoints de KPIs

## 🎯 Características Implementadas

### KPIsBloc
- ✅ Lista de agentes con filtros (rol, activo, búsqueda)
- ✅ KPI detallado de agente individual
- ✅ Overview general según rol del usuario
- ✅ KPI detallado para coordinadores
- ✅ **Polling automático cada 30 segundos**
- ✅ Refresh silencioso sin parpadeo en UI
- ✅ Cambio de rango de fechas (hoy, semana, mes, personalizado)
- ✅ Preservación de estado anterior en errores
- ✅ Gestión automática de timers

### Modelos con Getters Útiles
- `KPIAgenteListModel`: isDisponible, isEnLlamada, isPostcall, isDesconectado
- `KPIAgenteDetalleModel`: efectividadPorcentaje, cumpleObjetivo, promedioLlamadasPorHora
- `EquipoKPIModel`: porcentajeDisponibles, porcentajeEnLlamada, agentesOcupados
- `CampanaKPIModel`: cumpleObjetivoLlamadas, cumpleObjetivoVentas, isActiva
- `KPIOverviewModel`: isCoordinador, isJefeCampana, isAdmin

## 🔌 Endpoints Implementados

### 1. Listar Agentes KPI
```dart
KPIsService.listarAgentes({
  String? role,       // Filtrar por rol
  bool? isActive,     // Filtrar por estado activo
  String? search,     // Buscar por nombre o email
})
```
**Endpoint:** `GET /api/kpis/agentes/`

### 2. KPI Detallado de Agente
```dart
KPIsService.obtenerKPIAgente({
  required String documentoId,
  DateTime? fechaDesde,
  DateTime? fechaHasta,
  String? rango,      // hoy | semana | mes | personalizado
})
```
**Endpoint:** `GET /api/kpis/agentes/{documento_id}/detalle/`

### 3. Overview de KPIs
```dart
KPIsService.obtenerOverview({
  DateTime? fechaDesde,
  DateTime? fechaHasta,
  String? rango,
  int? campanaId,     // Filtrar por campaña
  int? equipoId,      // Filtrar por equipo
})
```
**Endpoint:** `GET /api/kpis/overview/`

### 4. KPIs de Coordinador
```dart
KPIsService.obtenerKPICoordinador({
  DateTime? fechaDesde,
  DateTime? fechaHasta,
  int? equipoId,
})
```
**Endpoint:** `GET /api/kpis/coordinador-detalle/`

## 📝 Ejemplos de Uso

### 1. Dashboard de KPIs con Polling Automático

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/kpis/kpis_bloc.dart';
import '../../blocs/kpis/kpis_event.dart';
import '../../blocs/kpis/kpis_state.dart';

class DashboardKPIView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KPIsBloc()..add(const LoadKPIOverview(rango: 'hoy')),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard KPIs'),
          actions: [
            // Selector de rango
            PopupMenuButton<String>(
              onSelected: (rango) {
                context.read<KPIsBloc>().add(ChangeKPIRango(rango: rango));
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'hoy', child: Text('Hoy')),
                const PopupMenuItem(value: 'semana', child: Text('Esta Semana')),
                const PopupMenuItem(value: 'mes', child: Text('Este Mes')),
              ],
            ),
          ],
        ),
        body: BlocBuilder<KPIsBloc, KPIsState>(
          builder: (context, state) {
            if (state is KPIsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is KPIOverviewLoaded) {
              final overview = state.overview;
              
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<KPIsBloc>().add(const RefreshKPIs());
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Indicador de última actualización
                        Row(
                          children: [
                            const Icon(Icons.update, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Actualizado: ${_formatTimestamp(state.timestamp)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const Spacer(),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'En vivo',
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Totales generales
                        _buildTotalesCard(overview.totales),
                        const SizedBox(height: 16),
                        
                        // Vista según rol
                        if (overview.isCoordinador && overview.equipos != null)
                          ..._buildEquiposSection(overview.equipos!),
                        
                        if (overview.isJefeCampana && overview.campanas != null)
                          ..._buildCampanasSection(overview.campanas!),
                        
                        if (overview.isAdmin && overview.centros != null)
                          ..._buildCentrosSection(overview.centros!),
                        
                        // Gráfica de llamadas por hora
                        if (overview.llamadasPorHora != null && overview.llamadasPorHora!.isNotEmpty)
                          _buildLlamadasPorHoraChart(overview.llamadasPorHora!),
                        
                        // Top agentes
                        if (overview.topAgentes != null && overview.topAgentes!.isNotEmpty)
                          _buildTopAgentesSection(overview.topAgentes!),
                      ],
                    ),
                  ),
                ),
              );
            }
            
            if (state is KPIsError) {
              // Mostrar estado anterior si existe
              if (state.previousState is KPIOverviewLoaded) {
                final prevState = state.previousState as KPIOverviewLoaded;
                return Column(
                  children: [
                    Container(
                      color: Colors.red.shade100,
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Error de conexión. Mostrando última actualización.',
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildOverviewContent(prevState.overview),
                    ),
                  ],
                );
              }
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<KPIsBloc>().add(const LoadKPIOverview());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            
            return const Center(child: Text('No hay datos disponibles'));
          },
        ),
      ),
    );
  }

  Widget _buildTotalesCard(Map<String, dynamic> totales) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Totales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Llamadas',
                  totales['total_llamadas']?.toString() ?? '0',
                  Icons.phone,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Ventas',
                  totales['ventas_realizadas']?.toString() ?? '0',
                  Icons.shopping_cart,
                  Colors.green,
                ),
                _buildStatItem(
                  'Conversión',
                  '${(totales['tasa_conversion'] ?? 0.0).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return 'hace ${diff.inSeconds}s';
    } else if (diff.inMinutes < 60) {
      return 'hace ${diff.inMinutes}m';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
```

### 2. KPI Detallado de Agente con Gráficas

```dart
class AgenteKPIDetalleView extends StatelessWidget {
  final String documentoId;

  const AgenteKPIDetalleView({Key? key, required this.documentoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KPIsBloc()..add(
        LoadKPIAgenteDetalle(documentoId: documentoId, rango: 'hoy'),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('KPI del Agente')),
        body: BlocBuilder<KPIsBloc, KPIsState>(
          builder: (context, state) {
            if (state is KPIAgenteDetalleLoaded) {
              final kpi = state.detalle;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con nombre y estado
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(kpi.agenteNombre[0]),
                        ),
                        title: Text(kpi.agenteNombre),
                        subtitle: Text(kpi.agenteEmail ?? ''),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getColorEstado(kpi.estadoActual),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            kpi.estadoActual ?? 'Sin estado',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // KPIs principales
                    Row(
                      children: [
                        Expanded(
                          child: _buildKPICard(
                            'Llamadas',
                            kpi.totalLlamadas.toString(),
                            Icons.phone,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildKPICard(
                            'Ventas',
                            kpi.ventasRealizadas.toString(),
                            Icons.shopping_cart,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKPICard(
                            'Conversión',
                            kpi.efectividadPorcentaje,
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildKPICard(
                            'Tiempo',
                            kpi.tiempoTrabajadoFormateado,
                            Icons.access_time,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Gráfica de llamadas por hora
                    if (kpi.llamadasPorHora != null && kpi.llamadasPorHora!.isNotEmpty) ...[
                      const Text(
                        'Llamadas por Hora',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: _buildLlamadasChart(kpi.llamadasPorHora!),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Distribución de estados
                    if (kpi.estadosDelDia != null && kpi.estadosDelDia!.isNotEmpty) ...[
                      const Text(
                        'Distribución de Estados',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...kpi.estadosDelDia!.map((estado) => 
                        _buildEstadoBar(estado),
                      ),
                    ],
                  ],
                ),
              );
            }
            
            if (state is KPIsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return const Center(child: Text('No hay datos'));
          },
        ),
      ),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoBar(EstadoDelDiaModel estado) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(estado.estadoValor),
              Text(
                '${estado.porcentaje.toStringAsFixed(1)}% (${estado.tiempoFormateado})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: estado.porcentaje / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getColorEstado(estado.estadoValor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorEstado(String? estado) {
    if (estado == null) return Colors.grey;
    switch (estado.toUpperCase()) {
      case 'DISPONIBLE':
        return Colors.green;
      case 'EN_LLAMADA':
        return Colors.blue;
      case 'POSTCALL':
        return Colors.orange;
      case 'DESCONECTADO':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
```

### 3. Lista de Agentes con KPIs

```dart
class ListaAgentesKPIView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KPIsBloc()..add(const LoadKPIAgentes()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agentes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<KPIsBloc, KPIsState>(
          builder: (context, state) {
            if (state is KPIAgentesLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<KPIsBloc>().add(const LoadKPIAgentes());
                },
                child: ListView.builder(
                  itemCount: state.agentes.length,
                  itemBuilder: (context, index) {
                    final agente = state.agentes[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColorEstado(agente.estadoActual),
                        child: Text(agente.nombreCompleto[0]),
                      ),
                      title: Text(agente.nombreCompleto),
                      subtitle: Text(agente.email),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getColorEstado(agente.estadoActual),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          agente.estadoActual,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgenteKPIDetalleView(
                              documentoId: agente.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }
            
            if (state is KPIsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return const Center(child: Text('No hay agentes'));
          },
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar Agentes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              onTap: () {
                context.read<KPIsBloc>().add(const LoadKPIAgentes());
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: const Text('Solo Activos'),
              onTap: () {
                context.read<KPIsBloc>().add(
                  const LoadKPIAgentes(isActive: true),
                );
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: const Text('Solo Disponibles'),
              onTap: () {
                // Usar búsqueda por estado en el backend si está disponible
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'DISPONIBLE':
        return Colors.green;
      case 'EN_LLAMADA':
        return Colors.blue;
      case 'POSTCALL':
        return Colors.orange;
      case 'DESCONECTADO':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
```

## 🎨 Mapeo de Estados a UI

| Estado | Acción UI |
|--------|-----------|
| `KPIsInitial` | Mostrar pantalla vacía o placeholder |
| `KPIsLoading` | Mostrar CircularProgressIndicator centrado |
| `KPIAgentesLoaded` | Mostrar ListView de agentes con estado |
| `KPIAgenteDetalleLoaded` | Mostrar dashboard con KPIs y gráficas |
| `KPIOverviewLoaded` | Mostrar vista general según rol |
| `KPICoordinadorLoaded` | Mostrar equipos del coordinador |
| `KPIsError` | Mostrar error o estado previo si existe |

## 🔧 Gestión de Polling

```dart
class MiVistaConKPIs extends StatefulWidget {
  @override
  State<MiVistaConKPIs> createState() => _MiVistaConKPIsState();
}

class _MiVistaConKPIsState extends State<MiVistaConKPIs> {
  late KPIsBloc _kpisBloc;

  @override
  void initState() {
    super.initState();
    _kpisBloc = KPIsBloc()..add(const LoadKPIOverview());
  }

  @override
  void dispose() {
    // Detener el polling antes de cerrar
    _kpisBloc.stopAutoRefresh();
    _kpisBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _kpisBloc,
      child: // ... tu contenido
    );
  }
}
```

## 📊 Colores por Estado

```dart
Color getColorEstado(String estado) {
  switch (estado.toUpperCase()) {
    case 'DISPONIBLE':
      return Colors.green;
    case 'EN_LLAMADA':
      return Colors.blue;
    case 'POSTCALL':
      return Colors.orange;
    case 'DESCONECTADO':
      return Colors.grey;
    default:
      return Colors.black;
  }
}

IconData getIconoEstado(String estado) {
  switch (estado.toUpperCase()) {
    case 'DISPONIBLE':
      return Icons.check_circle;
    case 'EN_LLAMADA':
      return Icons.phone_in_talk;
    case 'POSTCALL':
      return Icons.timer;
    case 'DESCONECTADO':
      return Icons.cancel;
    default:
      return Icons.help;
  }
}
```

## ⚡ Optimizaciones

- ✅ Polling automático solo se inicia después de cargar datos exitosamente
- ✅ Refresh silencioso (no emite `Loading`) para evitar parpadeo en UI
- ✅ Timer se cancela automáticamente en `close()` para evitar memory leaks
- ✅ Preservación de estado anterior en errores de conexión
- ✅ Cambio de rango sin perder contexto

## 🔒 Seguridad

- Todos los endpoints requieren autenticación JWT
- Los tokens se gestionan automáticamente por `AuthManager`
- `obtenerKPICoordinador` es solo para coordinadores
- Los datos se adaptan según el rol del usuario autenticado

## 📚 Resumen

- **Archivos creados**: 13 archivos (10 modelos + 1 servicio + 3 BLoC)
- **Endpoints**: 4 endpoints principales
- **Eventos**: 6 eventos
- **Estados**: 7 estados
- **Características especiales**: 
  - Polling cada 30 segundos
  - Vista adaptable por rol
  - Gráficas de llamadas por hora
  - Distribución de estados
  - Top agentes
  - Cambio de rango dinámico
  - Refresh silencioso
  - Preservación de estado

✅ **Todos los archivos compilan sin errores**
✅ **Listos para usar en las vistas**
✅ **Integración completa con el sistema de autenticación**
