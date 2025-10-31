# Módulo de Usuarios - Flutter (Versión Móvil)

## 📋 Descripción General

Este módulo gestiona los usuarios del sistema, sus permisos basados en roles (RBAC) y los estados de los agentes. Esta es una versión reducida para la aplicación móvil que incluye consultas de usuarios, actualización de perfil, cambio de contraseña y visualización de estados de agentes en tiempo real.

---

## 👥 Endpoints de Usuarios

### 1. Listar Usuarios
**URL:** `GET /api/users/`  
**Autenticación:** Requerida (Bearer Token)  
**Permisos:** Todos los roles (los agentes solo ven su información)  
**Descripción:** Lista usuarios según el rol

**Query Parameters:**
- `role` (opcional): Filtrar por rol (AGENTE, COORDINADOR, etc.)
- `is_active` (opcional): Filtrar por estado activo (true/false)
- `search` (opcional): Buscar por nombre o email

**Response Success (200):**
```json
{
  "count": 25,
  "next": "http://api.com/api/users/?page=2",
  "previous": null,
  "results": [
    {
      "id": "1234567890",
      "documento_id": "1234567890",
      "email": "agente@callcenter.com",
      "first_name": "Juan",
      "last_name": "Pérez",
      "full_name": "Juan Pérez",
      "phone": "+57 300 123 4567",
      "foto_perfil": "https://ejemplo.com/foto.jpg",
      "role": "AGENTE",
      "is_active": true,
      "is_staff": false,
      "is_superuser": false,
      "date_joined": "2025-01-15T10:30:00Z",
      "last_login": "2025-10-30T08:15:00Z"
    }
  ]
}
```

---

### 2. Obtener Usuario Específico
**URL:** `GET /api/users/{documento_id}/`  
**Autenticación:** Requerida  
**Permisos:** Admin o propietario del recurso  
**Descripción:** Obtiene información detallada de un usuario

**Response Success (200):**
```json
{
  "id": "1234567890",
  "documento_id": "1234567890",
  "email": "agente@callcenter.com",
  "first_name": "Juan",
  "last_name": "Pérez",
  "full_name": "Juan Pérez",
  "phone": "+57 300 123 4567",
  "foto_perfil": "https://ejemplo.com/foto.jpg",
  "role": "AGENTE",
  "is_active": true,
  "is_staff": false,
  "is_superuser": false,
  "date_joined": "2025-01-15T10:30:00Z",
  "last_login": "2025-10-30T08:15:00Z"
}
```

---

### 3. Actualizar Usuario
**URL:** `PATCH /api/users/{documento_id}/`  
**Autenticación:** Requerida  
**Permisos:** Admin o propietario  
**Descripción:** Actualiza información del usuario

**Request Body (Todos los campos opcionales):**
```json
{
  "first_name": "Juan Carlos",
  "last_name": "Pérez González",
  "phone": "+57 301 111 2222",
  "foto_perfil": "https://ejemplo.com/nueva_foto.jpg"
}
```

**Response Success (200):**
```json
{
  "id": "1234567890",
  "documento_id": "1234567890",
  "email": "agente@callcenter.com",
  "first_name": "Juan Carlos",
  "last_name": "Pérez González",
  "full_name": "Juan Carlos Pérez González",
  "phone": "+57 301 111 2222",
  "foto_perfil": "https://ejemplo.com/nueva_foto.jpg",
  "role": "AGENTE",
  "is_active": true
}
```

---

### 4. Cambiar Contraseña
**URL:** `POST /api/users/change-password/`  
**Autenticación:** Requerida  
**Descripción:** Permite al usuario cambiar su propia contraseña

**Request Body:**
```json
{
  "old_password": "PasswordActual123!",
  "new_password": "NuevaPassword123!",
  "new_password_confirm": "NuevaPassword123!"
}
```

**Response Success (200):**
```json
{
  "message": "Contraseña actualizada exitosamente"
}
```

**Errores Posibles:**
- `400 Bad Request`: Contraseña actual incorrecta o nuevas no coinciden

---

### 5. Obtener Perfil Actual
**URL:** `GET /api/users/me/`  
**Autenticación:** Requerida  
**Descripción:** Obtiene la información del usuario autenticado

**Response Success (200):**
```json
{
  "id": "1234567890",
  "documento_id": "1234567890",
  "email": "agente@callcenter.com",
  "first_name": "Juan",
  "last_name": "Pérez",
  "full_name": "Juan Pérez",
  "phone": "+57 300 123 4567",
  "foto_perfil": "https://ejemplo.com/foto.jpg",
  "role": "AGENTE",
  "is_active": true,
  "estado_actual": {
    "estado_id": 1,
    "estado_valor": "DISPONIBLE",
    "tiempo_en_estado_segundos": 1234,
    "tiempo_en_estado_formateado": "20:34"
  }
}
```

---

## 🔄 Endpoints de Estados de Agente

### 6. Obtener Estado Actual del Agente
**URL:** `GET /api/users/estados/current/`  
**Autenticación:** Requerida  
**Query Parameters:**
- `agente_id` (opcional, solo admin): ID del agente a consultar

**Response Success (200):**
```json
{
  "agente_id": "1234567890",
  "agente_nombre": "Juan Pérez",
  "estado_id": 1,
  "estado_valor": "DISPONIBLE",
  "tiempo": "2025-10-30T08:00:00-05:00",
  "tiempo_en_estado_segundos": 1234,
  "tiempo_en_estado_formateado": "20:34",
  "ultima_actualizacion": "2025-10-30T08:20:34-05:00"
}
```

---

### 7. Agentes Disponibles
**URL:** `GET /api/users/estados/disponibles/`  
**Autenticación:** Requerida  
**Permisos:** Solo Admin  
**Descripción:** Lista todos los agentes en estado DISPONIBLE

**Response Success (200):**
```json
[
  {
    "agente_id": "1234567890",
    "agente_nombre": "Juan Pérez",
    "estado_id": 1,
    "estado_valor": "DISPONIBLE",
    "tiempo_en_estado_segundos": 300
  },
  {
    "agente_id": "9876543210",
    "agente_nombre": "María López",
    "estado_id": 1,
    "estado_valor": "DISPONIBLE",
    "tiempo_en_estado_segundos": 150
  }
]
```

---

### 8. Todos los Estados Actuales
**URL:** `GET /api/users/estados/todos/`  
**Autenticación:** Requerida  
**Permisos:** Solo Admin  
**Descripción:** Lista los estados actuales de todos los agentes

**Response Success (200):**
```json
[
  {
    "agente_id": "1234567890",
    "agente_nombre": "Juan Pérez",
    "estado_id": 1,
    "estado_valor": "DISPONIBLE",
    "tiempo_en_estado_segundos": 300
  },
  {
    "agente_id": "9876543210",
    "agente_nombre": "María López",
    "estado_id": 2,
    "estado_valor": "EN_LLAMADA",
    "tiempo_en_estado_segundos": 120
  }
]
```

---

##  Modelos de Flutter

### 1. User Model (Extendido)
```dart
/// Modelo completo de usuario con estado actual
class UserModel {
  final String documentoId;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? phone;
  final String? fotoPerfil;
  final String role;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  
  /// Estado actual del agente (solo para agentes)
  final EstadoAgenteActualModel? estadoActual;

  UserModel({
    required this.documentoId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.phone,
    this.fotoPerfil,
    required this.role,
    required this.isActive,
    required this.isStaff,
    required this.isSuperuser,
    this.dateJoined,
    this.lastLogin,
    this.estadoActual,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      documentoId: json['documento_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      fotoPerfil: json['foto_perfil'],
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
      isStaff: json['is_staff'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
      dateJoined: json['date_joined'] != null 
        ? DateTime.parse(json['date_joined']) 
        : null,
      lastLogin: json['last_login'] != null 
        ? DateTime.parse(json['last_login']) 
        : null,
      estadoActual: json['estado_actual'] != null
        ? EstadoAgenteActualModel.fromJson(json['estado_actual'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documento_id': documentoId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'phone': phone,
      'foto_perfil': fotoPerfil,
      'role': role,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'date_joined': dateJoined?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'estado_actual': estadoActual?.toJson(),
    };
  }

  UserModel copyWith({
    String? documentoId,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phone,
    String? fotoPerfil,
    String? role,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    DateTime? dateJoined,
    DateTime? lastLogin,
    EstadoAgenteActualModel? estadoActual,
  }) {
    return UserModel(
      documentoId: documentoId ?? this.documentoId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      estadoActual: estadoActual ?? this.estadoActual,
    );
  }

  // Getters de roles
  bool get isAgent => role == 'AGENTE';
  bool get isCoordinator => role == 'COORDINADOR';
  bool get isJefeCampana => role == 'JEFE_CAMPANA' || role == 'JEFE DE CAMPAÑA';
  bool get isBackoffice => role == 'BACKOFFICE';
  bool get isAdmin => role == 'ADMIN';
  bool get isJefeCentro => role == 'JEFE_CENTRO' || role == 'JEFE DE CENTRO';
}
```

---

### 2. Estado Agente Actual Model
```dart
/// Modelo para el estado actual del agente en tiempo real
class EstadoAgenteActualModel {
  /// ID del agente
  final String agenteId;
  
  /// Nombre completo del agente
  final String agenteNombre;
  
  /// ID del estado actual
  final int estadoId;
  
  /// Valor del estado (DISPONIBLE, EN_LLAMADA, etc.)
  final String estadoValor;
  
  /// Timestamp de cuándo se inició este estado
  final DateTime tiempo;
  
  /// Tiempo transcurrido en este estado (en segundos)
  final int tiempoEnEstadoSegundos;
  
  /// Tiempo formateado (HH:MM o MM:SS)
  final String tiempoEnEstadoFormateado;
  
  /// Última actualización del registro
  final DateTime ultimaActualizacion;

  EstadoAgenteActualModel({
    required this.agenteId,
    required this.agenteNombre,
    required this.estadoId,
    required this.estadoValor,
    required this.tiempo,
    required this.tiempoEnEstadoSegundos,
    required this.tiempoEnEstadoFormateado,
    required this.ultimaActualizacion,
  });

  factory EstadoAgenteActualModel.fromJson(Map<String, dynamic> json) {
    return EstadoAgenteActualModel(
      agenteId: json['agente_id'] ?? '',
      agenteNombre: json['agente_nombre'] ?? '',
      estadoId: json['estado_id'] ?? 0,
      estadoValor: json['estado_valor'] ?? '',
      tiempo: DateTime.parse(json['tiempo']),
      tiempoEnEstadoSegundos: json['tiempo_en_estado_segundos'] ?? 0,
      tiempoEnEstadoFormateado: json['tiempo_en_estado_formateado'] ?? '00:00',
      ultimaActualizacion: DateTime.parse(json['ultima_actualizacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agente_id': agenteId,
      'agente_nombre': agenteNombre,
      'estado_id': estadoId,
      'estado_valor': estadoValor,
      'tiempo': tiempo.toIso8601String(),
      'tiempo_en_estado_segundos': tiempoEnEstadoSegundos,
      'tiempo_en_estado_formateado': tiempoEnEstadoFormateado,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
    };
  }

  /// Verifica si el agente está disponible
  bool get isDisponible => estadoValor == 'DISPONIBLE';

  /// Verifica si el agente está en llamada
  bool get isEnLlamada => estadoValor == 'EN_LLAMADA';

  /// Verifica si el agente está en postcall
  bool get isPostcall => estadoValor == 'POSTCALL';
}
```

---

### 3. Estado Agente Detalle Model
```dart
/// Modelo para el historial de estados del agente por día
class EstadoAgenteDetalleModel {
  final int id;
  final String agenteId;
  final String agenteNombre;
  final int estadoId;
  final String estadoValor;
  
  /// Tiempo total acumulado en el día en formato HH:MM:SS
  final String tiempo;
  
  /// Fecha del registro
  final DateTime fecha;
  
  /// Historial de cambios del día: "HH:MM:SS - nombre_usuario, ..."
  final String? cambios;

  EstadoAgenteDetalleModel({
    required this.id,
    required this.agenteId,
    required this.agenteNombre,
    required this.estadoId,
    required this.estadoValor,
    required this.tiempo,
    required this.fecha,
    this.cambios,
  });

  factory EstadoAgenteDetalleModel.fromJson(Map<String, dynamic> json) {
    return EstadoAgenteDetalleModel(
      id: json['id'] ?? 0,
      agenteId: json['agente_id'] ?? '',
      agenteNombre: json['agente_nombre'] ?? '',
      estadoId: json['estado_id'] ?? 0,
      estadoValor: json['estado_valor'] ?? '',
      tiempo: json['tiempo'] ?? '00:00:00',
      fecha: DateTime.parse(json['fecha']),
      cambios: json['cambios'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agente_id': agenteId,
      'agente_nombre': agenteNombre,
      'estado_id': estadoId,
      'estado_valor': estadoValor,
      'tiempo': tiempo,
      'fecha': fecha.toIso8601String(),
      'cambios': cambios,
    };
  }

  /// Convierte el tiempo HH:MM:SS a segundos
  int get tiempoEnSegundos {
    final parts = tiempo.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return (hours * 3600) + (minutes * 60) + seconds;
  }
}
```

---

### 4. Change Password Request Model
```dart
/// Modelo para cambiar contraseña
class ChangePasswordRequestModel {
  final String oldPassword;
  final String newPassword;
  final String newPasswordConfirm;

  ChangePasswordRequestModel({
    required this.oldPassword,
    required this.newPassword,
    required this.newPasswordConfirm,
  });

  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirm': newPasswordConfirm,
    };
  }

  bool get passwordsMatch => newPassword == newPasswordConfirm;
}
```

---

## 🔄 Sistema de Estados - Consideraciones Importantes

### 1. Estados Disponibles
```dart
enum EstadoAgente {
  disponible('DISPONIBLE'),
  enLlamada('EN_LLAMADA'),
  postcall('POSTCALL'),
  descanso('DESCANSO'),
  capacitacion('CAPACITACION'),
  reunion('REUNION'),
  desconectado('DESCONECTADO'),
  almuerzo('ALMUERZO'),
  bano('BAÑO');

  final String value;
  const EstadoAgente(this.value);
}
```

### 2. Timer en Tiempo Real
Para mostrar el tiempo en estado en tiempo real en la UI:

```dart
class AgentStateTimer extends StatefulWidget {
  final EstadoAgenteActualModel estado;

  @override
  _AgentStateTimerState createState() => _AgentStateTimerState();
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
    return Text(_formatTime(_secondsElapsed));
  }
}
```

### 3. Sincronización Periódica
Recomendación: Sincronizar con el backend cada 30 segundos para ajustar el drift del timer local.

---

## 📝 Permisos por Rol

| Endpoint | Agente | Coordinador | Jefe Campaña | Backoffice | Admin |
|----------|--------|-------------|--------------|------------|-------|
| GET /users/ | Solo él | Su equipo | Su campaña | Todos | Todos |
| GET /users/{id}/ | Solo él | Su equipo | Su campaña | Todos | Todos |
| PATCH /users/{id}/ | Solo él | ❌ | ❌ | ❌ | Todos |
| POST /users/change-password/ | ✅ | ✅ | ✅ | ✅ | ✅ |
| GET /users/estados/current/ | ✅ | ✅ | ✅ | ✅ | ✅ |
| GET /users/estados/disponibles/ | ❌ | ❌ | ❌ | ❌ | ✅ |
| GET /users/estados/todos/ | ❌ | ❌ | ❌ | ❌ | ✅ |

---

**Siguiente Módulo:** [03_CAMPANAS.md](./03_CAMPANAS.md)
