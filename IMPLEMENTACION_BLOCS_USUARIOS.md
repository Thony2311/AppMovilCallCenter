# Implementación de BLoCs del Módulo de Usuarios

## 📂 Estructura de BLoCs Creados

### BLoC de Usuarios (`lib/blocs/usuarios/`)
```
blocs/usuarios/
├── usuarios_event.dart         # 9 eventos
├── usuarios_state.dart         # 9 estados
└── usuarios_bloc.dart          # Lógica de gestión de usuarios
```

### BLoC de Estados (`lib/blocs/estados/`)
```
blocs/estados/
├── estados_event.dart          # 4 eventos
├── estados_state.dart          # 6 estados
└── estados_bloc.dart           # Lógica con polling automático
```

## 🎯 UsuariosBloc

### Eventos (usuarios_event.dart)

1. **LoadUsuarios** - Cargar lista de usuarios con filtros
   ```dart
   LoadUsuarios({
     String? role,
     bool? isActive,
     String? search,
     int page = 1,
   })
   ```

2. **LoadUsuarioById** - Cargar un usuario específico por documento
   ```dart
   LoadUsuarioById(String documentoId)
   ```

3. **LoadPerfilActual** - Cargar el perfil del usuario autenticado
   ```dart
   LoadPerfilActual()
   ```

4. **UpdateUsuario** - Actualizar información del usuario
   ```dart
   UpdateUsuario({
     required String documentoId,
     String? firstName,
     String? lastName,
     String? phone,
     String? fotoPerfil,
   })
   ```

5. **ChangePassword** - Cambiar contraseña
   ```dart
   ChangePassword(ChangePasswordRequestModel request)
   ```

6. **FilterUsuariosByRole** - Filtrar usuarios por rol
   ```dart
   FilterUsuariosByRole(String role)
   ```

7. **SearchUsuarios** - Buscar usuarios por término
   ```dart
   SearchUsuarios(String searchTerm)
   ```

8. **LoadMoreUsuarios** - Cargar más usuarios (paginación)
   ```dart
   LoadMoreUsuarios()
   ```

9. **RefreshUsuarios** - Refrescar la lista
   ```dart
   RefreshUsuarios()
   ```

### Estados (usuarios_state.dart)

1. **UsuariosInitial** - Estado inicial
2. **UsuariosLoading** - Cargando datos
3. **UsuariosLoaded** - Lista cargada exitosamente
   - `List<UsuarioModel> usuarios`
   - `int totalCount`
   - `bool hasMore`
   - `int currentPage`
   - `String? filtroRole`
   - `String? filtroSearch`
4. **UsuariosLoadingMore** - Cargando más usuarios (paginación)
5. **UsuarioDetailLoaded** - Detalle de un usuario cargado
6. **PerfilActualLoaded** - Perfil actual cargado
7. **UsuarioUpdated** - Usuario actualizado exitosamente
8. **PasswordChanged** - Contraseña cambiada exitosamente
9. **UsuariosError** - Error en alguna operación
   - `String message`
   - `List<UsuarioModel>? previousUsuarios` (preserva datos anteriores)

### Características del UsuariosBloc

- ✅ **Paginación**: Soporte completo para carga incremental
- ✅ **Filtros**: Por rol, estado activo, búsqueda
- ✅ **Preservación de Datos**: Mantiene datos anteriores en caso de error
- ✅ **Validación**: Valida requests antes de enviar (ej: cambio de contraseña)
- ✅ **Gestión de Estado**: copyWith para actualizaciones inmutables

## 🔄 EstadosBloc

### Eventos (estados_event.dart)

1. **LoadEstadoActual** - Cargar el estado actual del agente
   ```dart
   LoadEstadoActual()
   ```

2. **LoadAgentesDisponibles** - Cargar agentes disponibles (solo admin)
   ```dart
   LoadAgentesDisponibles()
   ```

3. **LoadTodosLosEstados** - Cargar todos los estados actuales (solo admin)
   ```dart
   LoadTodosLosEstados()
   ```

4. **RefreshEstado** - Refrescar el estado actual (polling interno)
   ```dart
   RefreshEstado()
   ```

### Estados (estados_state.dart)

1. **EstadosInitial** - Estado inicial
2. **EstadosLoading** - Cargando datos
3. **EstadoActualLoaded** - Estado actual cargado
   - `EstadoAgenteActualModel estadoActual`
   - `DateTime timestamp`
4. **AgentesDisponiblesLoaded** - Lista de agentes disponibles
   - `List<EstadoAgenteActualModel> agentes`
5. **TodosLosEstadosLoaded** - Todos los estados cargados
   - `List<EstadoAgenteActualModel> estados`
6. **EstadosError** - Error en alguna operación
   - `String message`
   - `EstadoAgenteActualModel? previousEstado` (preserva estado anterior)

### Características del EstadosBloc

- ✅ **Polling Automático**: Refresco cada 30 segundos
- ✅ **Gestión de Timer**: Timer se cancela automáticamente al cerrar el BLoC
- ✅ **Refresh Silencioso**: No muestra loading durante polling
- ✅ **Detección de Cambios**: Registra en logs cuando el estado cambia
- ✅ **Preservación de Estado**: Mantiene el estado anterior si falla el refresh
- ✅ **Control Manual**: Métodos `stopAutoRefresh()` para detener polling

## 📝 Ejemplos de Uso

### 1. Lista de Usuarios con Paginación

```dart
class ListaUsuariosView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsuariosBloc()..add(const LoadUsuarios()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Usuarios')),
        body: BlocBuilder<UsuariosBloc, UsuariosState>(
          builder: (context, state) {
            if (state is UsuariosLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is UsuariosLoaded) {
              return ListView.builder(
                itemCount: state.usuarios.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Cargar más al llegar al final
                  if (index == state.usuarios.length) {
                    context.read<UsuariosBloc>().add(const LoadMoreUsuarios());
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final usuario = state.usuarios[index];
                  return ListTile(
                    title: Text(usuario.fullName),
                    subtitle: Text(usuario.role),
                    trailing: Icon(
                      usuario.isActive ? Icons.check_circle : Icons.cancel,
                      color: usuario.isActive ? Colors.green : Colors.red,
                    ),
                  );
                },
              );
            }
            
            if (state is UsuariosError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            
            return const Center(child: Text('No hay usuarios'));
          },
        ),
      ),
    );
  }
}
```

### 2. Filtrar Usuarios por Rol

```dart
// En un PopupMenuButton o DropdownButton
PopupMenuButton<String>(
  onSelected: (role) {
    context.read<UsuariosBloc>().add(FilterUsuariosByRole(role));
  },
  itemBuilder: (context) => [
    const PopupMenuItem(value: 'AGENTE', child: Text('Agentes')),
    const PopupMenuItem(value: 'COORDINADOR', child: Text('Coordinadores')),
    const PopupMenuItem(value: 'JEFE_CAMPANA', child: Text('Jefes de Campaña')),
    const PopupMenuItem(value: 'JEFE_CENTRO', child: Text('Jefes de Centro')),
  ],
)
```

### 3. Buscar Usuarios

```dart
TextField(
  decoration: const InputDecoration(
    labelText: 'Buscar usuarios',
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (value) {
    context.read<UsuariosBloc>().add(SearchUsuarios(value));
  },
)
```

### 4. Ver Perfil Actual

```dart
class PerfilView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsuariosBloc()..add(const LoadPerfilActual()),
      child: BlocBuilder<UsuariosBloc, UsuariosState>(
        builder: (context, state) {
          if (state is PerfilActualLoaded) {
            final perfil = state.perfil;
            return Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: perfil.fotoPerfil != null
                      ? NetworkImage(perfil.fotoPerfil!)
                      : null,
                  child: perfil.fotoPerfil == null
                      ? Text(perfil.initials)
                      : null,
                ),
                Text(perfil.fullName),
                Text(perfil.role),
                Text(perfil.email),
              ],
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
```

### 5. Actualizar Usuario

```dart
ElevatedButton(
  onPressed: () {
    context.read<UsuariosBloc>().add(
      UpdateUsuario(
        documentoId: '123456',
        firstName: 'Juan',
        lastName: 'Pérez',
        phone: '3001234567',
      ),
    );
  },
  child: const Text('Actualizar'),
)

// Escuchar el resultado
BlocListener<UsuariosBloc, UsuariosState>(
  listener: (context, state) {
    if (state is UsuarioUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.green),
      );
    }
  },
  child: // ... tu widget
)
```

### 6. Cambiar Contraseña

```dart
final request = ChangePasswordRequestModel(
  documentoId: '123456',
  currentPassword: 'oldpass',
  newPassword: 'newpass123',
  confirmNewPassword: 'newpass123',
);

// Validar antes de enviar
if (!request.isValid) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(request.validationError!)),
  );
  return;
}

// Enviar el cambio
context.read<UsuariosBloc>().add(ChangePassword(request));

// Escuchar el resultado
BlocListener<UsuariosBloc, UsuariosState>(
  listener: (context, state) {
    if (state is PasswordChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      // Navegar al login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  },
  child: // ... tu widget
)
```

### 7. Estado del Agente en Tiempo Real

```dart
class EstadoAgenteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EstadosBloc()..add(const LoadEstadoActual()),
      child: BlocBuilder<EstadosBloc, EstadosState>(
        builder: (context, state) {
          if (state is EstadoActualLoaded) {
            final estado = state.estadoActual;
            return Card(
              child: ListTile(
                leading: Icon(
                  estado.isDisponible ? Icons.check_circle : Icons.phone_in_talk,
                  color: estado.isDisponible ? Colors.green : Colors.blue,
                ),
                title: Text(estado.estadoValor),
                subtitle: Text('Tiempo: ${estado.tiempoEnEstadoFormateado}'),
                trailing: Text(
                  'Actualizado hace ${DateTime.now().difference(state.timestamp).inSeconds}s',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          }
          
          if (state is EstadosError && state.previousEstado != null) {
            // Mostrar estado anterior si falla el refresh
            final estado = state.previousEstado!;
            return Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(estado.estadoValor),
                subtitle: const Text('Conexión perdida. Último estado conocido.'),
              ),
            );
          }
          
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
```

### 8. Detener Polling al Salir de la Vista

```dart
class MiVistaConEstados extends StatefulWidget {
  @override
  State<MiVistaConEstados> createState() => _MiVistaConEstadosState();
}

class _MiVistaConEstadosState extends State<MiVistaConEstados> {
  late EstadosBloc _estadosBloc;

  @override
  void initState() {
    super.initState();
    _estadosBloc = EstadosBloc()..add(const LoadEstadoActual());
  }

  @override
  void dispose() {
    // Detener el polling antes de cerrar
    _estadosBloc.stopAutoRefresh();
    _estadosBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _estadosBloc,
      child: // ... tu contenido
    );
  }
}
```

## 🎨 Mapeo de Estados a UI

### UsuariosBloc

| Estado | Acción UI |
|--------|-----------|
| `UsuariosInitial` | Mostrar pantalla vacía o placeholder |
| `UsuariosLoading` | Mostrar CircularProgressIndicator centrado |
| `UsuariosLoaded` | Mostrar ListView con RefreshIndicator |
| `UsuariosLoadingMore` | Mostrar progress indicator al final de la lista |
| `UsuarioDetailLoaded` | Mostrar pantalla de detalle del usuario |
| `PerfilActualLoaded` | Mostrar perfil editable con formulario |
| `UsuarioUpdated` | SnackBar verde + recargar datos |
| `PasswordChanged` | SnackBar verde + navegar a login |
| `UsuariosError` | Mostrar mensaje de error con botón "Reintentar" |

### EstadosBloc

| Estado | Acción UI |
|--------|-----------|
| `EstadosInitial` | Mostrar placeholder vacío |
| `EstadosLoading` | Mostrar CircularProgressIndicator |
| `EstadoActualLoaded` | Mostrar Card con estado, tiempo, icono, timestamp |
| `AgentesDisponiblesLoaded` | Mostrar lista de agentes disponibles |
| `TodosLosEstadosLoaded` | Mostrar grid/lista de todos los estados |
| `EstadosError` | Mostrar error o estado previo con indicador de desconexión |

## 🔧 Configuración de Colores para Estados

```dart
Color getColorEstado(String estadoValor) {
  switch (estadoValor.toUpperCase()) {
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

IconData getIconoEstado(String estadoValor) {
  switch (estadoValor.toUpperCase()) {
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

## 📊 Gestión de Paginación

```dart
// El BLoC maneja automáticamente la paginación
BlocBuilder<UsuariosBloc, UsuariosState>(
  builder: (context, state) {
    if (state is UsuariosLoaded) {
      return ListView.builder(
        itemCount: state.usuarios.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Detectar cuando llegamos al final
          if (index == state.usuarios.length) {
            // Solo cargar si no estamos ya cargando más
            if (state is! UsuariosLoadingMore) {
              context.read<UsuariosBloc>().add(const LoadMoreUsuarios());
            }
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          final usuario = state.usuarios[index];
          return ListTile(title: Text(usuario.fullName));
        },
      );
    }
    return const CircularProgressIndicator();
  },
)
```

## ⚡ Optimizaciones

### UsuariosBloc
- ✅ Preserva datos anteriores en `UsuariosError` para evitar pérdida de información
- ✅ Validación de request antes de enviar (ej: `ChangePasswordRequestModel.isValid`)
- ✅ Búsqueda limpia filtros previos para evitar conflictos
- ✅ `RefreshUsuarios` mantiene los filtros activos actuales

### EstadosBloc
- ✅ Polling automático solo se inicia después de cargar el estado con éxito
- ✅ Refresh silencioso (no emite `Loading`) para evitar parpadeo en UI
- ✅ Timer se cancela automáticamente en `close()` para evitar memory leaks
- ✅ Detección de cambios de estado para notificar solo cuando cambia

## 🔒 Seguridad

- Todos los endpoints requieren autenticación JWT
- Los tokens se gestionan automáticamente por `AuthManager`
- `obtenerAgentesDisponibles` y `obtenerTodosLosEstados` son solo para administradores
- El cambio de contraseña requiere la contraseña actual para verificar identidad
- Las validaciones se hacen tanto en cliente (BLoC) como en servidor

## 📚 Resumen

- **Archivos creados**: 6 archivos (3 de usuarios + 3 de estados)
- **Eventos totales**: 13 (9 usuarios + 4 estados)
- **Estados totales**: 15 (9 usuarios + 6 estados)
- **Características especiales**: 
  - Paginación automática
  - Polling cada 30 segundos
  - Preservación de datos en errores
  - Validaciones pre-request
  - Refresh silencioso
  - Gestión automática de timers

✅ **Todos los archivos compilan sin errores**
✅ **Listos para usar en las vistas**
