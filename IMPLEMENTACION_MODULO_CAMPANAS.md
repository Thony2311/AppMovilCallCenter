# Implementación del Módulo de Campañas - Resumen

## ✅ Implementación Completa

Se ha adaptado exitosamente el módulo de campañas al formato del proyecto Flutter, organizando todos los componentes según la arquitectura establecida.

---

## 📁 Estructura de Archivos Creados

### 📦 **Modelos** (lib/models/)

#### Campañas (`lib/models/campanas/`)
- ✅ `campana_model.dart` - Modelo completo de campaña con getters útiles (isActiva, isPausada, diasRestantes, etc.)
- ✅ `campana_simple_model.dart` - Modelo simplificado para referencias rápidas

#### Clientes (`lib/models/clientes/`)
- ✅ `cliente_model.dart` - Modelo de cliente con soporte para datos JSON flexibles (otros_datos)

#### Equipos (`lib/models/equipos/`)
- ✅ `equipo_model.dart` - Modelo de equipo con lista de agentes y referencia a campaña
- ✅ `agente_simple_model.dart` - Modelo simplificado de agente para listas

---

### 🔌 **Servicios API** (lib/services/)

- ✅ `campanas_service.dart` - 6 métodos: listar, obtener, filtrar por estado/jefe/centro
- ✅ `clientes_service.dart` - 5 métodos: listar, obtener, buscar, filtrar por campaña/base de datos
- ✅ `equipos_service.dart` - 6 métodos: listar, obtener, filtrar por campaña/coordinador/estado

**Características de los servicios:**
- Autenticación JWT automática con AuthManager
- Manejo de errores con mensajes descriptivos
- Logs detallados con AppLogger
- Soporte para paginación
- Type-safe con casting explícito

---

### 🧩 **BLoCs** (lib/blocs/)

#### Campañas (`lib/blocs/campanas/`)
- ✅ `campanas_event.dart` - 6 eventos (LoadCampanas, LoadCampanaById, LoadCampanasActivas, FilterCampanasByEstado, LoadMoreCampanas, RefreshCampanas)
- ✅ `campanas_state.dart` - 6 estados (Initial, Loading, Loaded, LoadingMore, DetailLoaded, Error)
- ✅ `campanas_bloc.dart` - Lógica completa con paginación y filtros

#### Clientes (`lib/blocs/clientes/`)
- ✅ `clientes_event.dart` - 5 eventos (LoadClientes, LoadClienteById, SearchClientes, LoadMoreClientes, RefreshClientes)
- ✅ `clientes_state.dart` - 6 estados (Initial, Loading, Loaded, LoadingMore, DetailLoaded, Error)
- ✅ `clientes_bloc.dart` - Lógica con búsqueda y paginación

#### Equipos (`lib/blocs/equipos/`)
- ✅ `equipos_event.dart` - 4 eventos (LoadEquipos, LoadEquipoById, LoadEquiposActivos, RefreshEquipos)
- ✅ `equipos_state.dart` - 5 estados (Initial, Loading, Loaded, DetailLoaded, Error)
- ✅ `equipos_bloc.dart` - Lógica de gestión de equipos

---

### ⚙️ **Configuración**

- ✅ `lib/config/api_config.dart` actualizado con 6 nuevos endpoints:
  - `campanasEndpoint` - GET /api/campaigns/
  - `campanaDetailEndpoint` - GET /api/campaigns/{id}/
  - `clientesEndpoint` - GET /api/campaigns/clientes/
  - `clienteDetailEndpoint` - GET /api/campaigns/clientes/{cliente_id}/
  - `equiposEndpoint` - GET /api/campaigns/equipos/
  - `equipoDetailEndpoint` - GET /api/campaigns/equipos/{equipo_id}/

---

## 🎯 Características Implementadas

### 1. **Modelos**
- ✅ Serialización completa (fromJson/toJson)
- ✅ Type-safe con null-safety
- ✅ Getters útiles (isActiva, isContactable, tieneAgentes, etc.)
- ✅ Métodos copyWith para inmutabilidad
- ✅ Equals y HashCode sobrecargados
- ✅ Soporte para datos JSON flexibles en clientes (otros_datos)

### 2. **Servicios**
- ✅ Integración con AuthManager para JWT
- ✅ Manejo de errores HTTP (401, 403, 404)
- ✅ Logging automático con AppLogger
- ✅ Métodos helper específicos (listarCampanasActivas, buscarClientes, etc.)
- ✅ Soporte para query parameters y filtros
- ✅ Decodificación UTF-8 correcta

### 3. **BLoCs**
- ✅ Patrón Event-State con Equatable
- ✅ Paginación implementada (LoadMore events)
- ✅ Refresh/Pull-to-refresh
- ✅ Estados de carga diferenciados (Loading, LoadingMore)
- ✅ Manejo de errores con estados Error
- ✅ Preservación de datos previos en errores

---

## 📊 Endpoints Disponibles

### Campañas
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/campaigns/` | Lista campañas con filtros opcionales |
| GET | `/api/campaigns/{id}/` | Detalle de campaña específica |

**Filtros soportados:**
- `estado` (ACTIVA, PAUSADA, FINALIZADA)
- `jefe_campana` (documento del jefe)
- `centro` (ID del centro)
- `page` (paginación)

### Clientes
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/campaigns/clientes/` | Lista clientes con filtros |
| GET | `/api/campaigns/clientes/{cliente_id}/` | Detalle de cliente |

**Filtros soportados:**
- `campana` (ID de campaña)
- `search` (nombre o teléfono)
- `base_datos` (ID de base de datos)
- `page` (paginación)

### Equipos
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/campaigns/equipos/` | Lista equipos con filtros |
| GET | `/api/campaigns/equipos/{equipo_id}/` | Detalle de equipo con agentes |

**Filtros soportados:**
- `campana` (ID de campaña)
- `coordinador` (documento del coordinador)
- `is_active` (true/false)
- `page` (paginación)

---

## 🚀 Cómo Usar en las Vistas

### Ejemplo 1: Listar Campañas Activas

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/campanas/campanas_bloc.dart';
import '../blocs/campanas/campanas_event.dart';
import '../blocs/campanas/campanas_state.dart';

class CampanasView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CampanasBloc()..add(const LoadCampanasActivas()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Campañas Activas')),
        body: BlocBuilder<CampanasBloc, CampanasState>(
          builder: (context, state) {
            if (state is CampanasLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is CampanasError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            
            if (state is CampanasLoaded) {
              return ListView.builder(
                itemCount: state.campanas.length,
                itemBuilder: (context, index) {
                  final campana = state.campanas[index];
                  return ListTile(
                    title: Text(campana.nombre),
                    subtitle: Text(campana.estadoNombre),
                    trailing: Icon(
                      Icons.circle,
                      color: campana.isActiva ? Colors.green : Colors.grey,
                    ),
                    onTap: () {
                      // Navegar a detalle
                      context.read<CampanasBloc>().add(
                        LoadCampanaById(campana.id),
                      );
                    },
                  );
                },
              );
            }
            
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
```

### Ejemplo 2: Buscar Clientes

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/clientes/clientes_bloc.dart';
import '../blocs/clientes/clientes_event.dart';
import '../blocs/clientes/clientes_state.dart';

class BuscarClientesView extends StatefulWidget {
  final int campanaId;

  const BuscarClientesView({required this.campanaId});

  @override
  State<BuscarClientesView> createState() => _BuscarClientesViewState();
}

class _BuscarClientesViewState extends State<BuscarClientesView> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClientesBloc()..add(
        LoadClientes(campana: widget.campanaId),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buscar Clientes'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o teléfono',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  if (value.length >= 3) {
                    context.read<ClientesBloc>().add(
                      SearchClientes(value, campanaId: widget.campanaId),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        body: BlocBuilder<ClientesBloc, ClientesState>(
          builder: (context, state) {
            if (state is ClientesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ClientesLoaded) {
              if (state.clientes.isEmpty) {
                return const Center(
                  child: Text('No se encontraron clientes'),
                );
              }
              
              return ListView.builder(
                itemCount: state.clientes.length,
                itemBuilder: (context, index) {
                  final cliente = state.clientes[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(cliente.nombre[0].toUpperCase()),
                      ),
                      title: Text(cliente.nombre),
                      subtitle: Text(cliente.telefonoFormateado),
                      trailing: cliente.isContactable
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  );
                },
              );
            }
            
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
```

### Ejemplo 3: Ver Equipo con Agentes

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/equipos/equipos_bloc.dart';
import '../blocs/equipos/equipos_event.dart';
import '../blocs/equipos/equipos_state.dart';

class EquipoDetalleView extends StatelessWidget {
  final int equipoId;

  const EquipoDetalleView({required this.equipoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EquiposBloc()..add(LoadEquipoById(equipoId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalle del Equipo')),
        body: BlocBuilder<EquiposBloc, EquiposState>(
          builder: (context, state) {
            if (state is EquiposLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is EquipoDetailLoaded) {
              final equipo = state.equipo;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del equipo
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipo.nombre,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            if (equipo.coordinadorNombre != null)
                              Text('Coordinador: ${equipo.coordinadorNombre}'),
                            if (equipo.campanaInfo != null)
                              Text('Campaña: ${equipo.campanaInfo!.nombre}'),
                            Text('Estado: ${equipo.estadoTexto}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Lista de agentes
                    Text(
                      'Agentes (${equipo.cantidadAgentes})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...equipo.agentes.map((agente) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(agente.iniciales),
                        ),
                        title: Text(agente.fullName),
                        subtitle: Text(agente.email),
                        trailing: agente.codigoAgente != null
                            ? Chip(label: Text(agente.codigoAgente!))
                            : null,
                      ),
                    )),
                  ],
                ),
              );
            }
            
            if (state is EquiposError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
```

---

## ✅ Validación

Todos los archivos han sido compilados y validados sin errores:
- ✅ 5 modelos sin errores de compilación
- ✅ 3 servicios API funcionando correctamente
- ✅ 9 archivos BLoC (3 eventos + 3 estados + 3 blocs) validados
- ✅ Configuración de API actualizada

---

## 📝 Notas Importantes

1. **Jerarquía de Permisos**: Los servicios respetan automáticamente la jerarquía de roles (Agente → Coordinador → Jefe Campaña → Jefe Centro) a través del backend.

2. **Paginación**: Todos los servicios de listado soportan paginación. Usa los eventos `LoadMore*` en los BLoCs para cargar más resultados.

3. **Búsqueda**: El servicio de clientes incluye búsqueda por nombre o teléfono. La búsqueda se activa automáticamente con el evento `SearchClientes`.

4. **Estados de Campaña**: Los modelos de campaña incluyen getters útiles como `isActiva`, `isPausada`, `isFinalizada` y `diasRestantes`.

5. **Datos Flexibles**: El modelo de cliente soporta campos adicionales en JSON a través de `otrosDatos`, accesibles con `getOtroDato(key)`.

---

## 🎉 Siguiente Paso

Los modelos, servicios y BLoCs están listos para ser utilizados en las vistas. Para implementar interfaces de usuario:

1. Importa los BLoCs necesarios en tus vistas
2. Usa `BlocProvider` para proporcionar el BLoC
3. Usa `BlocBuilder` o `BlocConsumer` para escuchar cambios de estado
4. Dispara eventos para cargar/filtrar/buscar datos

**Ejemplo de integración completa disponible arriba ☝️**
