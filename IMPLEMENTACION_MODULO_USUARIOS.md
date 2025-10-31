# Implementación del Módulo de Usuarios - Aplicación Móvil

## 📦 Archivos Creados/Modificados

### ✅ Nuevos Modelos Creados

1. **`lib/models/estado_agente_actual_model.dart`**
   - Modelo para representar el estado actual de un agente en tiempo real
   - Incluye información como estado, tiempo transcurrido, y métodos helpers
   - Getters útiles: `isDisponible`, `isEnLlamada`, `isPostcall`, `isDesconectado`

2. **`lib/models/estado_agente_detalle_model.dart`**
   - Modelo para el historial de estados del agente por día
   - Representa tiempo acumulado en cada estado
   - Convierte tiempo HH:MM:SS a segundos

3. **`lib/models/change_password_request_model.dart`**
   - Modelo para solicitudes de cambio de contraseña
   - Incluye validaciones: passwords match, longitud mínima, campos no vacíos
   - Método `validationError` retorna mensaje de error si aplica

### ✏️ Modelos Actualizados

4. **`lib/models/usuario_model.dart`**
   - ✅ Agregado campo `dateJoined` (DateTime?)
   - ✅ Agregado campo `lastLogin` (DateTime?)
   - ✅ Agregado campo `estadoActual` (EstadoAgenteActualModel?)
   - ✅ Agregado getter `isJefeCentro`
   - ✅ Actualizado `fromJson` para parsear los nuevos campos
   - ✅ Actualizado `toJson` para serializar los nuevos campos
   - ✅ Actualizado `copyWith` para incluir nuevos campos

### 🔧 Configuración Actualizada

5. **`lib/config/api_config.dart`**
   - ✅ Agregados endpoints de usuarios:
     - `usersEndpoint`: GET /api/users/
     - `userDetailEndpoint`: GET/PATCH /api/users/{documento_id}/
     - `userMeEndpoint`: GET /api/users/me/
     - `changePasswordEndpoint`: POST /api/users/change-password/
   - ✅ Agregados endpoints de estados:
     - `estadoCurrentEndpoint`: GET /api/users/estados/current/
     - `estadosDisponiblesEndpoint`: GET /api/users/estados/disponibles/
     - `estadosTodosEndpoint`: GET /api/users/estados/todos/

### 🌐 Nuevo Servicio

6. **`lib/services/user_service.dart`**
   - Servicio completo para gestión de usuarios y estados
   - Implementa los 8 endpoints documentados:

#### Endpoints de Usuarios (1-5):
1. **`listarUsuarios()`** - Lista usuarios con filtros opcionales (role, is_active, search, page)
2. **`obtenerUsuario(documentoId)`** - Obtiene usuario específico
3. **`actualizarUsuario()`** - Actualiza información del usuario (firstName, lastName, phone, fotoPerfil)
4. **`cambiarContrasena(request)`** - Cambia la contraseña del usuario
5. **`obtenerPerfilActual()`** - Obtiene perfil del usuario autenticado con su estado actual

#### Endpoints de Estados (6-8):
6. **`obtenerEstadoActual({agenteId})`** - Obtiene estado actual del agente
7. **`obtenerAgentesDisponibles()`** - Lista agentes en estado DISPONIBLE (solo admin)
8. **`obtenerTodosLosEstados()`** - Lista estados de todos los agentes (solo admin)

---

## 🔐 Jerarquía de Permisos Implementada

El endpoint **5. Obtener Perfil Actual** (`GET /api/users/me/`) respeta la siguiente jerarquía:

| Rol | Permisos de Visualización |
|-----|---------------------------|
| **Agente** | Solo ve su propia información y estado |
| **Coordinador** | Ve su información, su estado y la de todos los agentes de su equipo |
| **Jefe de Campaña** | Ve su información, la de coordinadores y agentes de toda su campaña |
| **Jefe de Centro** | Ve toda la información del centro (acceso completo) |

### Flujo de Uso:
```dart
// Al iniciar sesión, el usuario obtiene su perfil
final perfil = await UserService.obtenerPerfilActual();

// El perfil incluye:
// - Información básica del usuario
// - Su estado actual (si es agente)
// - Información de su equipo (si es coordinador+)

// Según el rol, verá diferente información:
if (perfil.isAgent) {
  // Solo ve su propio estado
  final miEstado = perfil.estadoActual;
}

if (perfil.isCoordinator) {
  // Puede ver estados de su equipo
  final agentes = await UserService.listarUsuarios(role: 'AGENTE');
}

if (perfil.isJefeCentro || perfil.isAdmin) {
  // Puede ver todos los estados
  final todosEstados = await UserService.obtenerTodosLosEstados();
}
```

---

## 📝 Ejemplos de Uso

### 1. Obtener Perfil al Iniciar Sesión
```dart
try {
  final perfil = await UserService.obtenerPerfilActual();
  
  print('Usuario: ${perfil.fullName}');
  print('Rol: ${perfil.role}');
  
  if (perfil.estadoActual != null) {
    print('Estado: ${perfil.estadoActual!.estadoValor}');
    print('Tiempo en estado: ${perfil.estadoActual!.tiempoEnEstadoFormateado}');
  }
} catch (e) {
  print('Error al obtener perfil: $e');
}
```

### 2. Listar Agentes del Equipo (Coordinador)
```dart
try {
  final resultado = await UserService.listarUsuarios(
    role: 'AGENTE',
    isActive: true,
  );
  
  final agentes = resultado['results'] as List<UsuarioModel>;
  print('Total de agentes activos: ${resultado['count']}');
  
  for (final agente in agentes) {
    print('- ${agente.fullName}: ${agente.estadoActual?.estadoValor ?? "Sin estado"}');
  }
} catch (e) {
  print('Error al listar agentes: $e');
}
```

### 3. Actualizar Perfil del Usuario
```dart
try {
  final usuarioActualizado = await UserService.actualizarUsuario(
    documentoId: '1234567890',
    firstName: 'Juan Carlos',
    phone: '+57 301 111 2222',
  );
  
  print('Perfil actualizado: ${usuarioActualizado.fullName}');
} catch (e) {
  print('Error al actualizar perfil: $e');
}
```

### 4. Cambiar Contraseña
```dart
try {
  final request = ChangePasswordRequestModel(
    oldPassword: 'MiPasswordActual123!',
    newPassword: 'MiNuevaPassword123!',
    newPasswordConfirm: 'MiNuevaPassword123!',
  );
  
  // Validar antes de enviar
  if (!request.isValid) {
    print('Error: ${request.validationError}');
    return;
  }
  
  final mensaje = await UserService.cambiarContrasena(request);
  print(mensaje); // "Contraseña actualizada exitosamente"
} catch (e) {
  print('Error al cambiar contraseña: $e');
}
```

### 5. Ver Estado Actual del Agente
```dart
try {
  // Sin parámetros: obtiene el estado del usuario autenticado
  final miEstado = await UserService.obtenerEstadoActual();
  
  print('Mi estado: ${miEstado.estadoValor}');
  print('Tiempo: ${miEstado.tiempoEnEstadoFormateado}');
  
  // Con parámetro (solo admin): obtiene estado de otro agente
  final estadoAgente = await UserService.obtenerEstadoActual(
    agenteId: '9876543210'
  );
} catch (e) {
  print('Error al obtener estado: $e');
}
```

### 6. Ver Agentes Disponibles (Admin)
```dart
try {
  final disponibles = await UserService.obtenerAgentesDisponibles();
  
  print('Agentes disponibles: ${disponibles.length}');
  
  for (final agente in disponibles) {
    print('- ${agente.agenteNombre}');
    print('  Disponible por: ${agente.tiempoEnEstadoFormateado}');
  }
} catch (e) {
  print('Error: $e');
}
```

### 7. Ver Todos los Estados (Admin)
```dart
try {
  final estados = await UserService.obtenerTodosLosEstados();
  
  // Agrupar por estado
  final porEstado = <String, int>{};
  for (final estado in estados) {
    porEstado[estado.estadoValor] = (porEstado[estado.estadoValor] ?? 0) + 1;
  }
  
  print('Resumen de estados:');
  porEstado.forEach((estado, cantidad) {
    print('$estado: $cantidad agentes');
  });
} catch (e) {
  print('Error: $e');
}
```

---

## 🔄 Integración con el Login Existente

El modelo `UsuarioModel` ahora incluye el campo `estadoActual`, por lo que cuando un usuario se loguea, ya recibe su estado actual (si es agente):

```dart
// En el LoginBloc o LoginService, después del login exitoso:
final loginResponse = await LoginApi.login(email, password);

// El usuario ya incluye su estado actual
final usuario = loginResponse.user;

if (usuario.estadoActual != null) {
  // Mostrar el estado en la UI
  print('Estado: ${usuario.estadoActual!.estadoValor}');
  print('Tiempo: ${usuario.estadoActual!.tiempoEnEstadoFormateado}');
}
```

---

## 📊 Widget de Estado en Tiempo Real

Para mostrar el estado del agente con timer en tiempo real:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/estado_agente_actual_model.dart';

class AgentStateTimer extends StatefulWidget {
  final EstadoAgenteActualModel estado;

  const AgentStateTimer({Key? key, required this.estado}) : super(key: key);

  @override
  State<AgentStateTimer> createState() => _AgentStateTimerState();
}

class _AgentStateTimerState extends State<AgentStateTimer> {
  late Timer _timer;
  late int _secondsElapsed;

  @override
  void initState() {
    super.initState();
    _secondsElapsed = widget.estado.tiempoEnEstadoSegundos;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.estado.estadoValor,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(_secondsElapsed),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
```

---

## ✅ Checklist de Implementación

- [x] Modelos de estado de agente creados
- [x] Modelo de cambio de contraseña creado
- [x] UsuarioModel extendido con campos adicionales
- [x] Endpoints de usuarios agregados a ApiConfig
- [x] Endpoints de estados agregados a ApiConfig
- [x] UserService implementado con todos los endpoints
- [x] Documentación de jerarquía de permisos
- [x] Ejemplos de uso proporcionados
- [x] Widget de estado en tiempo real
- [x] Validaciones de tipos en modelos
- [x] Manejo de errores en servicios
- [x] Logging con AppLogger

---

## 🚀 Próximos Pasos

1. **Crear BLoC para gestión de usuarios** (opcional, si se prefiere arquitectura BLoC)
2. **Implementar UI para ver perfil de usuario**
3. **Implementar UI para actualizar perfil**
4. **Implementar UI para cambio de contraseña**
5. **Agregar widget de estado en dashboards según rol**
6. **Implementar sincronización periódica de estados** (cada 30 segundos recomendado)
7. **Agregar notificaciones cuando cambien estados de agentes** (para coordinadores+)

---

## 📌 Notas Importantes

- **Backend decide los permisos**: La jerarquía de permisos se maneja en el backend. El endpoint `/api/users/me/` retorna diferente información según el rol del usuario autenticado.
- **Estados solo para agentes**: El campo `estadoActual` solo viene poblado para usuarios con rol AGENTE.
- **Sincronización recomendada**: Se recomienda sincronizar el estado cada 30 segundos para ajustar el drift del timer local.
- **Tokens JWT**: El servicio usa automáticamente el token de acceso almacenado en `AuthManager`.

---

**Última actualización**: 30 de octubre de 2025
