# Módulo de Campañas - Flutter (Versión Simplificada)

## 📋 Descripción General

Este módulo gestiona campañas, equipos y clientes. Versión simplificada enfocada en consulta de información.

---

## 📢 Endpoints de Campañas

### 1. Listar Campañas
**URL:** `GET /api/campaigns/`  
**Autenticación:** Requerida  
**Descripción:** Lista todas las campañas según permisos del rol

**Query Parameters:**
- `estado` (opcional): Filtrar por estado (ACTIVA, PAUSADA, FINALIZADA)
- `jefe_campana` (opcional): Filtrar por jefe de campaña
- `centro` (opcional): Filtrar por centro

**Response Success (200):**
```json
{
  "count": 15,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "nombre": "Campaña Primavera 2025",
      "descripcion": "Venta de servicios",
      "fecha_inicio": "2025-01-01",
      "fecha_fin": "2025-12-31",
      "estado": 5,
      "estado_nombre": "ACTIVA",
      "objetivo_llamadas": 10000,
      "objetivo_ventas": 2000,
      "jefe_campana": "9876543210",
      "centro": 1,
      "centro_nombre": "Centro Norte",
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

---

### 2. Obtener Campaña Específica
**URL:** `GET /api/campaigns/{id}/`  
**Autenticación:** Requerida

**Response Success (200):**
```json
{
  "id": 1,
  "nombre": "Campaña Primavera 2025",
  "descripcion": "Venta de servicios",
  "fecha_inicio": "2025-01-01",
  "fecha_fin": "2025-12-31",
  "estado": 5,
  "estado_nombre": "ACTIVA",
  "objetivo_llamadas": 10000,
  "objetivo_ventas": 2000,
  "jefe_campana": {
    "documento_id": "9876543210",
    "full_name": "Carlos Rodríguez",
    "email": "carlos@callcenter.com"
  },
  "centro": {
    "id": 1,
    "nombre": "Centro Norte",
    "direccion": "Calle 100 # 20-30"
  },
  "productos": [
    {
      "id": 1,
      "nombre": "Servicio Premium",
      "precio": "99.99"
    }
  ],
  "equipos": [
    {
      "equipo_id": 1,
      "nombre": "Equipo A",
      "cantidad_agentes": 5
    }
  ],
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z"
}
```

---

## 👥 Endpoints de Clientes

### 3. Listar Clientes
**URL:** `GET /api/campaigns/clientes/`  
**Autenticación:** Requerida  
**Query Parameters:**
- `campana` (opcional): Filtrar por campaña
- `search` (opcional): Buscar por nombre o teléfono
- `base_datos` (opcional): Filtrar por base de datos cargada

**Response Success (200):**
```json
{
  "count": 500,
  "next": "http://api.com/api/campaigns/clientes/?page=2",
  "previous": null,
  "results": [
    {
      "cliente_id": 1,
      "campana": 1,
      "nombre": "Pedro Martínez",
      "telefono": "+57 301 234 5678",
      "base_datos": 10,
      "documento_id": "123456789",
      "email": "pedro@email.com",
      "direccion": "Calle 50 # 10-20",
      "observaciones": "Cliente potencial",
      "otros_datos": {
        "edad": 35,
        "ciudad": "Bogotá"
      }
    }
  ]
}
```

---

### 4. Obtener Cliente Específico
**URL:** `GET /api/campaigns/clientes/{cliente_id}/`  
**Autenticación:** Requerida

**Response Success (200):**
```json
{
  "cliente_id": 1,
  "campana": 1,
  "nombre": "Pedro Martínez",
  "telefono": "+57 301 234 5678",
  "base_datos": 10,
  "documento_id": "123456789",
  "email": "pedro@email.com",
  "direccion": "Calle 50 # 10-20",
  "observaciones": "Cliente potencial",
  "otros_datos": {
    "edad": 35,
    "ciudad": "Bogotá",
    "genero": "M"
  }
}
```

---

## 👨‍👩‍👧‍👦 Endpoints de Equipos

### 6. Listar Equipos
**URL:** `GET /api/campaigns/equipos/`  
**Autenticación:** Requerida  
**Query Parameters:**
- `campana` (opcional): Filtrar por campaña
- `coordinador` (opcional): Filtrar por coordinador
- `is_active` (opcional): Filtrar activos/inactivos

**Response Success (200):**
```json
{
  "count": 10,
  "next": null,
  "previous": null,
  "results": [
    {
      "equipo_id": 1,
      "nombre": "Equipo A",
      "centro_nombre": "Centro Norte",
      "coordinador": "1112223334",
      "coordinador_nombre": "Ana García",
      "campana": 1,
      "campana_info": {
        "id": 1,
        "nombre": "Campaña Primavera 2025",
        "estado": 5,
        "estado_nombre": "ACTIVA"
      },
      "agentes": [
        {
          "documento_id": "1234567890",
          "full_name": "Juan Pérez",
          "email": "juan@callcenter.com",
          "codigo_agente": "123456"
        }
      ],
      "cantidad_agentes": 5,
      "is_active": true
    }
  ]
}
```

---

### 7. Obtener Equipo Específico
**URL:** `GET /api/campaigns/equipos/{equipo_id}/`  
**Autenticación:** Requerida

**Response Success (200):**
```json
{
  "equipo_id": 1,
  "nombre": "Equipo A",
  "centro_nombre": "Centro Norte",
  "coordinador": "1112223334",
  "coordinador_nombre": "Ana García",
  "campana": 1,
  "campana_info": {
    "id": 1,
    "nombre": "Campaña Primavera 2025",
    "descripcion": "Venta de servicios",
    "estado": 5,
    "estado_nombre": "ACTIVA",
    "fecha_inicio": "2025-01-01",
    "fecha_fin": "2025-12-31",
    "jefe_campana": "9876543210",
    "centro": 1,
    "objetivo_llamadas": 10000,
    "objetivo_ventas": 2000
  },
  "agentes": [
    {
      "documento_id": "1234567890",
      "first_name": "Juan",
      "last_name": "Pérez",
      "full_name": "Juan Pérez",
      "email": "juan@callcenter.com",
      "codigo_agente": "123456"
    },
    {
      "documento_id": "9876543210",
      "first_name": "María",
      "last_name": "López",
      "full_name": "María López",
      "email": "maria@callcenter.com",
      "codigo_agente": "987654"
    }
  ],
  "cantidad_agentes": 2,
  "is_active": true
}
```

---

## 📦 Modelos de Flutter

### 1. Campaña Model
```dart
/// Modelo para representar una campaña del call center
class CampanaModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int estadoId;
  final String estadoNombre;
  final int? objetivoLlamadas;
  final int? objetitoVentas;
  final String? jefeCampanaId;
  final int? centroId;
  final String? centroNombre;
  final DateTime createdAt;
  final DateTime updatedAt;

  CampanaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.estadoId,
    required this.estadoNombre,
    this.objetivoLlamadas,
    this.objetitoVentas,
    this.jefeCampanaId,
    this.centroId,
    this.centroNombre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampanaModel.fromJson(Map<String, dynamic> json) {
    return CampanaModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: json['fecha_fin'] != null 
        ? DateTime.parse(json['fecha_fin']) 
        : null,
      estadoId: json['estado'] ?? 0,
      estadoNombre: json['estado_nombre'] ?? '',
      objetivoLlamadas: json['objetivo_llamadas'],
      objetitoVentas: json['objetivo_ventas'],
      jefeCampanaId: json['jefe_campana']?.toString(),
      centroId: json['centro'],
      centroNombre: json['centro_nombre'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'estado': estadoId,
      'estado_nombre': estadoNombre,
      'objetivo_llamadas': objetivoLlamadas,
      'objetivo_ventas': objetitoVentas,
      'jefe_campana': jefeCampanaId,
      'centro': centroId,
      'centro_nombre': centroNombre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Verifica si la campaña está activa
  bool get isActiva => estadoNombre == 'ACTIVA';

  /// Verifica si la campaña está pausada
  bool get isPausada => estadoNombre == 'PAUSADA';

  /// Verifica si la campaña finalizó
  bool get isFinalizada => estadoNombre == 'FINALIZADA';
}
```

---

### 2. Cliente Model
```dart
/// Modelo para representar un cliente de una campaña
class ClienteModel {
  final int clienteId;
  final int campanaId;
  final String nombre;
  final String telefono;
  final int? baseDatosId;
  
  /// Campos extraídos de otros_datos JSON
  final String? documentoId;
  final String? email;
  final String? direccion;
  final String? observaciones;
  
  /// Datos adicionales en formato JSON
  final Map<String, dynamic>? otrosDatos;

  ClienteModel({
    required this.clienteId,
    required this.campanaId,
    required this.nombre,
    required this.telefono,
    this.baseDatosId,
    this.documentoId,
    this.email,
    this.direccion,
    this.observaciones,
    this.otrosDatos,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      clienteId: json['cliente_id'] ?? 0,
      campanaId: json['campana'] ?? 0,
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'] ?? '',
      baseDatosId: json['base_datos'],
      documentoId: json['documento_id'],
      email: json['email'],
      direccion: json['direccion'],
      observaciones: json['observaciones'],
      otrosDatos: json['otros_datos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': clienteId,
      'campana': campanaId,
      'nombre': nombre,
      'telefono': telefono,
      'base_datos': baseDatosId,
      'documento_id': documentoId,
      'email': email,
      'direccion': direccion,
      'observaciones': observaciones,
      'otros_datos': otrosDatos,
    };
  }

  /// Crea una copia con campos actualizados (para edición)
  ClienteModel copyWith({
    int? clienteId,
    int? campanaId,
    String? nombre,
    String? telefono,
    int? baseDatosId,
    String? documentoId,
    String? email,
    String? direccion,
    String? observaciones,
    Map<String, dynamic>? otrosDatos,
  }) {
    return ClienteModel(
      clienteId: clienteId ?? this.clienteId,
      campanaId: campanaId ?? this.campanaId,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      baseDatosId: baseDatosId ?? this.baseDatosId,
      documentoId: documentoId ?? this.documentoId,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      observaciones: observaciones ?? this.observaciones,
      otrosDatos: otrosDatos ?? this.otrosDatos,
    );
  }

  /// Valida si tiene información completa para contactar
  bool get isContactable => telefono.isNotEmpty || email != null;
}
```

---

### 3. Equipo Model
```dart
/// Modelo para representar un equipo de agentes
class EquipoModel {
  final int equipoId;
  final String nombre;
  final String? centroNombre;
  final String? coordinadorId;
  final String? coordinadorNombre;
  final int? campanaId;
  final CampanaSimpleModel? campanaInfo;
  final List<AgenteSimpleModel> agentes;
  final int cantidadAgentes;
  final bool isActive;

  EquipoModel({
    required this.equipoId,
    required this.nombre,
    this.centroNombre,
    this.coordinadorId,
    this.coordinadorNombre,
    this.campanaId,
    this.campanaInfo,
    required this.agentes,
    required this.cantidadAgentes,
    required this.isActive,
  });

  factory EquipoModel.fromJson(Map<String, dynamic> json) {
    return EquipoModel(
      equipoId: json['equipo_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      centroNombre: json['centro_nombre'],
      coordinadorId: json['coordinador']?.toString(),
      coordinadorNombre: json['coordinador_nombre'],
      campanaId: json['campana'],
      campanaInfo: json['campana_info'] != null
          ? CampanaSimpleModel.fromJson(json['campana_info'])
          : null,
      agentes: (json['agentes'] as List<dynamic>?)
              ?.map((a) => AgenteSimpleModel.fromJson(a))
              .toList() ??
          [],
      cantidadAgentes: json['cantidad_agentes'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipo_id': equipoId,
      'nombre': nombre,
      'centro_nombre': centroNombre,
      'coordinador': coordinadorId,
      'coordinador_nombre': coordinadorNombre,
      'campana': campanaId,
      'campana_info': campanaInfo?.toJson(),
      'agentes': agentes.map((a) => a.toJson()).toList(),
      'cantidad_agentes': cantidadAgentes,
      'is_active': isActive,
    };
  }
}

/// Modelo simplificado de campaña (usado en Equipo)
class CampanaSimpleModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final int estadoId;
  final String estadoNombre;
  final DateTime fechaInicio;
  final DateTime? fechaFin;

  CampanaSimpleModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.estadoId,
    required this.estadoNombre,
    required this.fechaInicio,
    this.fechaFin,
  });

  factory CampanaSimpleModel.fromJson(Map<String, dynamic> json) {
    return CampanaSimpleModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      estadoId: json['estado'] ?? 0,
      estadoNombre: json['estado_nombre'] ?? '',
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: json['fecha_fin'] != null 
        ? DateTime.parse(json['fecha_fin']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estadoId,
      'estado_nombre': estadoNombre,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
    };
  }
}

/// Modelo simplificado de agente (usado en Equipo)
class AgenteSimpleModel {
  final String documentoId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? codigoAgente;

  AgenteSimpleModel({
    required this.documentoId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.codigoAgente,
  });

  factory AgenteSimpleModel.fromJson(Map<String, dynamic> json) {
    return AgenteSimpleModel(
      documentoId: json['documento_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      codigoAgente: json['codigo_agente'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documento_id': documentoId,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'codigo_agente': codigoAgente,
    };
  }
}
```

---

## 📝 Notas Importantes

### 1. Relación Equipo-Campaña-Centro
- Un equipo está asignado a UNA campaña
- La campaña pertenece a UN centro
- Por lo tanto, el centro del equipo se obtiene indirectamente a través de la campaña

### 2. Estados de Campaña
```dart
enum EstadoCampana {
  activa('ACTIVA'),
  pausada('PAUSADA'),
  finalizada('FINALIZADA');

  final String value;
  const EstadoCampana(this.value);
}
```

---

**Siguiente Módulo:** [04_KPIS.md](./04_KPIS.md)
