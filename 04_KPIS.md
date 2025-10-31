# Módulo de KPIs - Flutter

## 📋 Descripción General

Este módulo proporciona métricas y estadísticas en tiempo real del sistema. Incluye KPIs por agente, equipo, coordinador y vista general (overview) para diferentes roles.

---

## 📊 Endpoints de KPIs

### 1. Listar Agentes (Vista KPI)
**URL:** `GET /api/kpis/agentes/`  
**Autenticación:** Requerida  
**Descripción:** Lista agentes con información básica para KPIs

**Query Parameters:**
- `role` (opcional): Filtrar por rol
- `is_active` (opcional): Filtrar activos/inactivos
- `search` (opcional): Buscar por nombre o email

**Response Success (200):**
```json
[
  {
    "id": "1234567890",
    "nombre_completo": "Juan Pérez",
    "email": "juan@callcenter.com",
    "phone": "+57 300 123 4567",
    "estado_actual": "DISPONIBLE"
  },
  {
    "id": "9876543210",
    "nombre_completo": "María López",
    "email": "maria@callcenter.com",
    "phone": "+57 301 987 6543",
    "estado_actual": "EN_LLAMADA"
  }
]
```

---

### 2. KPI Detallado de Agente
**URL:** `GET /api/kpis/agentes/{documento_id}/detalle/`  
**Autenticación:** Requerida  
**Descripción:** Obtiene KPIs detallados de un agente específico

**Query Parameters:**
- `fecha_desde` (opcional): YYYY-MM-DD (default: hoy)
- `fecha_hasta` (opcional): YYYY-MM-DD (default: hoy)
- `rango` (opcional): hoy | semana | mes | personalizado (default: hoy)

**Response Success (200):**
```json
{
  "agente_id": "1234567890",
  "agente_nombre": "Juan Pérez",
  "agente_email": "juan@callcenter.com",
  "fecha_desde": "2025-10-30",
  "fecha_hasta": "2025-10-30",
  "total_llamadas": 45,
  "ventas_realizadas": 12,
  "tasa_conversion": 26.67,
  "tiempo_trabajado_segundos": 28800,
  "tiempo_trabajado_formateado": "08:00:00",
  "duracion_promedio_segundos": 180.5,
  "duracion_promedio_formateado": "03:00",
  "estado_actual": "DISPONIBLE",
  "llamadas_por_hora": [
    {
      "hora": 8,
      "cantidad": 5,
      "ventas": 1
    },
    {
      "hora": 9,
      "cantidad": 7,
      "ventas": 2
    },
    {
      "hora": 10,
      "cantidad": 6,
      "ventas": 1
    }
  ],
  "estados_del_dia": [
    {
      "estado_valor": "DISPONIBLE",
      "tiempo_segundos": 18000,
      "tiempo_formateado": "05:00:00",
      "porcentaje": 62.5
    },
    {
      "estado_valor": "EN_LLAMADA",
      "tiempo_segundos": 8100,
      "tiempo_formateado": "02:15:00",
      "porcentaje": 28.13
    },
    {
      "estado_valor": "POSTCALL",
      "tiempo_segundos": 2700,
      "tiempo_formateado": "00:45:00",
      "porcentaje": 9.37
    }
  ]
}
```

---

### 3. Overview de KPIs (Vista General)
**URL:** `GET /api/kpis/overview/`  
**Autenticación:** Requerida  
**Descripción:** Vista general de KPIs según el rol del usuario

**Query Parameters:**
- `fecha_desde` (opcional): YYYY-MM-DD
- `fecha_hasta` (opcional): YYYY-MM-DD
- `rango` (opcional): hoy | semana | mes | personalizado
- `campana` (opcional): ID de campaña (para filtrar)
- `equipo` (opcional): ID de equipo (para filtrar)

**Response Success (200) - Para COORDINADOR:**
```json
{
  "tipo_usuario": "COORDINADOR",
  "fecha_desde": "2025-10-30",
  "fecha_hasta": "2025-10-30",
  "equipos": [
    {
      "equipo_id": 1,
      "equipo_nombre": "Equipo A",
      "campana_nombre": "Campaña Primavera 2025",
      "total_agentes": 5,
      "agentes_disponibles": 3,
      "agentes_en_llamada": 2,
      "agentes_postcall": 0,
      "total_llamadas": 125,
      "ventas_realizadas": 32,
      "tasa_conversion": 25.6,
      "tiempo_promedio_llamada_segundos": 195,
      "tiempo_promedio_llamada_formateado": "03:15"
    }
  ],
  "totales": {
    "total_agentes": 5,
    "agentes_disponibles": 3,
    "agentes_en_llamada": 2,
    "total_llamadas": 125,
    "ventas_realizadas": 32,
    "tasa_conversion": 25.6
  }
}
```

**Response Success (200) - Para JEFE DE CAMPAÑA:**
```json
{
  "tipo_usuario": "JEFE_CAMPANA",
  "fecha_desde": "2025-10-30",
  "fecha_hasta": "2025-10-30",
  "campanas": [
    {
      "campana_id": 1,
      "campana_nombre": "Campaña Primavera 2025",
      "estado_campana": "ACTIVA",
      "objetivo_llamadas": 10000,
      "objetivo_ventas": 2000,
      "total_equipos": 3,
      "total_agentes": 15,
      "agentes_disponibles": 8,
      "agentes_en_llamada": 5,
      "agentes_otros_estados": 2,
      "total_llamadas": 450,
      "ventas_realizadas": 105,
      "tasa_conversion": 23.33,
      "progreso_llamadas_porcentaje": 4.5,
      "progreso_ventas_porcentaje": 5.25,
      "equipos": [
        {
          "equipo_id": 1,
          "equipo_nombre": "Equipo A",
          "coordinador_nombre": "Ana García",
          "total_agentes": 5,
          "total_llamadas": 125,
          "ventas_realizadas": 32
        }
      ]
    }
  ],
  "totales": {
    "total_campanas": 1,
    "total_equipos": 3,
    "total_agentes": 15,
    "total_llamadas": 450,
    "ventas_realizadas": 105,
    "tasa_conversion": 23.33
  }
}
```

**Response Success (200) - Para BACKOFFICE/ADMIN:**
```json
{
  "tipo_usuario": "ADMIN",
  "fecha_desde": "2025-10-30",
  "fecha_hasta": "2025-10-30",
  "centros": [
    {
      "centro_id": 1,
      "centro_nombre": "Centro Norte",
      "jefe_centro_nombre": "Carlos Rodríguez",
      "total_campanas": 3,
      "total_equipos": 8,
      "total_agentes": 40,
      "agentes_disponibles": 20,
      "agentes_en_llamada": 15,
      "total_llamadas": 1250,
      "ventas_realizadas": 310,
      "tasa_conversion": 24.8
    }
  ],
  "totales_sistema": {
    "total_centros": 3,
    "total_campanas": 8,
    "total_equipos": 25,
    "total_agentes": 150,
    "agentes_activos_hoy": 145,
    "agentes_disponibles": 75,
    "agentes_en_llamada": 50,
    "total_llamadas": 4500,
    "ventas_realizadas": 1100,
    "tasa_conversion": 24.44,
    "tiempo_promedio_llamada_segundos": 185,
    "tiempo_promedio_llamada_formateado": "03:05"
  },
  "llamadas_por_hora": [
    {
      "hora": 8,
      "cantidad": 250,
      "ventas": 62
    },
    {
      "hora": 9,
      "cantidad": 320,
      "ventas": 78
    }
  ],
  "top_agentes": [
    {
      "agente_id": "1234567890",
      "agente_nombre": "Juan Pérez",
      "total_llamadas": 55,
      "ventas_realizadas": 18,
      "tasa_conversion": 32.73
    }
  ]
}
```

---

### 4. KPIs de Coordinador (Detallado)
**URL:** `GET /api/kpis/coordinador-detalle/`  
**Autenticación:** Requerida  
**Permisos:** Solo COORDINADOR  
**Descripción:** Vista detallada para coordinadores de sus equipos

**Query Parameters:**
- `fecha_desde` (opcional): YYYY-MM-DD
- `fecha_hasta` (opcional): YYYY-MM-DD
- `equipo_id` (opcional): ID específico de equipo

**Response Success (200):**
```json
{
  "coordinador_id": "1112223334",
  "coordinador_nombre": "Ana García",
  "fecha_desde": "2025-10-30",
  "fecha_hasta": "2025-10-30",
  "equipos": [
    {
      "equipo_id": 1,
      "equipo_nombre": "Equipo A",
      "campana_id": 1,
      "campana_nombre": "Campaña Primavera 2025",
      "agentes": [
        {
          "agente_id": "1234567890",
          "agente_nombre": "Juan Pérez",
          "estado_actual": "DISPONIBLE",
          "tiempo_en_estado_segundos": 300,
          "total_llamadas": 12,
          "ventas_realizadas": 3,
          "tasa_conversion": 25.0,
          "tiempo_trabajado_segundos": 7200,
          "tiempo_trabajado_formateado": "02:00:00"
        }
      ],
      "totales_equipo": {
        "total_agentes": 5,
        "agentes_disponibles": 3,
        "agentes_en_llamada": 2,
        "total_llamadas": 45,
        "ventas_realizadas": 12,
        "tasa_conversion": 26.67
      }
    }
  ]
}
```

---

## 📦 Modelos de Flutter

### 1. KPI Agente List Model
```dart
/// Modelo simplificado de agente para listas de KPI
class KPIAgenteListModel {
  final String id;
  final String nombreCompleto;
  final String email;
  final String? phone;
  final String estadoActual;

  KPIAgenteListModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    this.phone,
    required this.estadoActual,
  });

  factory KPIAgenteListModel.fromJson(Map<String, dynamic> json) {
    return KPIAgenteListModel(
      id: json['id'] ?? '',
      nombreCompleto: json['nombre_completo'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      estadoActual: json['estado_actual'] ?? 'DESCONECTADO',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_completo': nombreCompleto,
      'email': email,
      'phone': phone,
      'estado_actual': estadoActual,
    };
  }

  /// Verifica si el agente está disponible
  bool get isDisponible => estadoActual == 'DISPONIBLE';
}
```

---

### 2. KPI Agente Detalle Model
```dart
/// Modelo detallado de KPIs de un agente
class KPIAgenteDetalleModel {
  // Información del agente
  final String agenteId;
  final String agenteNombre;
  final String? agenteEmail;
  
  // Período de reporte
  final DateTime fechaDesde;
  final DateTime fechaHasta;
  
  // KPIs principales
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion; // Porcentaje 0-100
  
  // Tiempo trabajado
  final int tiempoTrabajadoSegundos;
  final String tiempoTrabajadoFormateado;
  
  // Duración de llamadas
  final double duracionPromedioSegundos;
  final String duracionPromedioFormateado;
  
  // Estado actual
  final String? estadoActual;
  
  // Series para gráficas
  final List<LlamadaPorHoraModel>? llamadasPorHora;
  final List<EstadoDelDiaModel>? estadosDelDia;

  KPIAgenteDetalleModel({
    required this.agenteId,
    required this.agenteNombre,
    this.agenteEmail,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
    required this.tiempoTrabajadoSegundos,
    required this.tiempoTrabajadoFormateado,
    required this.duracionPromedioSegundos,
    required this.duracionPromedioFormateado,
    this.estadoActual,
    this.llamadasPorHora,
    this.estadosDelDia,
  });

  factory KPIAgenteDetalleModel.fromJson(Map<String, dynamic> json) {
    return KPIAgenteDetalleModel(
      agenteId: json['agente_id'] ?? '',
      agenteNombre: json['agente_nombre'] ?? '',
      agenteEmail: json['agente_email'],
      fechaDesde: DateTime.parse(json['fecha_desde']),
      fechaHasta: DateTime.parse(json['fecha_hasta']),
      totalLlamadas: json['total_llamadas'] ?? 0,
      ventasRealizadas: json['ventas_realizadas'] ?? 0,
      tasaConversion: (json['tasa_conversion'] ?? 0.0).toDouble(),
      tiempoTrabajadoSegundos: json['tiempo_trabajado_segundos'] ?? 0,
      tiempoTrabajadoFormateado: json['tiempo_trabajado_formateado'] ?? '00:00:00',
      duracionPromedioSegundos: (json['duracion_promedio_segundos'] ?? 0.0).toDouble(),
      duracionPromedioFormateado: json['duracion_promedio_formateado'] ?? '00:00',
      estadoActual: json['estado_actual'],
      llamadasPorHora: (json['llamadas_por_hora'] as List<dynamic>?)
          ?.map((item) => LlamadaPorHoraModel.fromJson(item))
          .toList(),
      estadosDelDia: (json['estados_del_dia'] as List<dynamic>?)
          ?.map((item) => EstadoDelDiaModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agente_id': agenteId,
      'agente_nombre': agenteNombre,
      'agente_email': agenteEmail,
      'fecha_desde': fechaDesde.toIso8601String(),
      'fecha_hasta': fechaHasta.toIso8601String(),
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
      'tiempo_trabajado_segundos': tiempoTrabajadoSegundos,
      'tiempo_trabajado_formateado': tiempoTrabajadoFormateado,
      'duracion_promedio_segundos': duracionPromedioSegundos,
      'duracion_promedio_formateado': duracionPromedioFormateado,
      'estado_actual': estadoActual,
      'llamadas_por_hora': llamadasPorHora?.map((l) => l.toJson()).toList(),
      'estados_del_dia': estadosDelDia?.map((e) => e.toJson()).toList(),
    };
  }

  /// Calcula el porcentaje de efectividad
  String get efectividadPorcentaje => '${tasaConversion.toStringAsFixed(2)}%';

  /// Indica si cumple con un objetivo de conversión
  bool cumpleObjetivo(double objetivoPorcentaje) => 
    tasaConversion >= objetivoPorcentaje;
}

/// Modelo auxiliar para gráfica de llamadas por hora
class LlamadaPorHoraModel {
  final int hora;
  final int cantidad;
  final int ventas;

  LlamadaPorHoraModel({
    required this.hora,
    required this.cantidad,
    required this.ventas,
  });

  factory LlamadaPorHoraModel.fromJson(Map<String, dynamic> json) {
    return LlamadaPorHoraModel(
      hora: json['hora'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      ventas: json['ventas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hora': hora,
      'cantidad': cantidad,
      'ventas': ventas,
    };
  }

  /// Tasa de conversión de esta hora
  double get tasaConversion => 
    cantidad > 0 ? (ventas / cantidad) * 100 : 0.0;
}

/// Modelo auxiliar para distribución de estados del día
class EstadoDelDiaModel {
  final String estadoValor;
  final int tiempoSegundos;
  final String tiempoFormateado;
  final double porcentaje;

  EstadoDelDiaModel({
    required this.estadoValor,
    required this.tiempoSegundos,
    required this.tiempoFormateado,
    required this.porcentaje,
  });

  factory EstadoDelDiaModel.fromJson(Map<String, dynamic> json) {
    return EstadoDelDiaModel(
      estadoValor: json['estado_valor'] ?? '',
      tiempoSegundos: json['tiempo_segundos'] ?? 0,
      tiempoFormateado: json['tiempo_formateado'] ?? '00:00:00',
      porcentaje: (json['porcentaje'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estado_valor': estadoValor,
      'tiempo_segundos': tiempoSegundos,
      'tiempo_formateado': tiempoFormateado,
      'porcentaje': porcentaje,
    };
  }
}
```

---

### 3. KPI Overview Model
```dart
/// Modelo para la vista general de KPIs
/// Estructura adaptable según el rol del usuario
class KPIOverviewModel {
  final String tipoUsuario;
  final DateTime fechaDesde;
  final DateTime fechaHasta;
  
  // Datos específicos según rol
  final List<EquipoKPIModel>? equipos; // Para COORDINADOR
  final List<CampanaKPIModel>? campanas; // Para JEFE_CAMPANA
  final List<CentroKPIModel>? centros; // Para ADMIN/BACKOFFICE
  
  // Totales generales
  final Map<String, dynamic> totales;
  
  // Datos adicionales opcionales
  final List<LlamadaPorHoraModel>? llamadasPorHora;
  final List<TopAgenteModel>? topAgentes;

  KPIOverviewModel({
    required this.tipoUsuario,
    required this.fechaDesde,
    required this.fechaHasta,
    this.equipos,
    this.campanas,
    this.centros,
    required this.totales,
    this.llamadasPorHora,
    this.topAgentes,
  });

  factory KPIOverviewModel.fromJson(Map<String, dynamic> json) {
    return KPIOverviewModel(
      tipoUsuario: json['tipo_usuario'] ?? '',
      fechaDesde: DateTime.parse(json['fecha_desde']),
      fechaHasta: DateTime.parse(json['fecha_hasta']),
      equipos: (json['equipos'] as List<dynamic>?)
          ?.map((e) => EquipoKPIModel.fromJson(e))
          .toList(),
      campanas: (json['campanas'] as List<dynamic>?)
          ?.map((c) => CampanaKPIModel.fromJson(c))
          .toList(),
      centros: (json['centros'] as List<dynamic>?)
          ?.map((c) => CentroKPIModel.fromJson(c))
          .toList(),
      totales: json['totales'] ?? json['totales_sistema'] ?? {},
      llamadasPorHora: (json['llamadas_por_hora'] as List<dynamic>?)
          ?.map((l) => LlamadaPorHoraModel.fromJson(l))
          .toList(),
      topAgentes: (json['top_agentes'] as List<dynamic>?)
          ?.map((t) => TopAgenteModel.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_usuario': tipoUsuario,
      'fecha_desde': fechaDesde.toIso8601String(),
      'fecha_hasta': fechaHasta.toIso8601String(),
      'equipos': equipos?.map((e) => e.toJson()).toList(),
      'campanas': campanas?.map((c) => c.toJson()).toList(),
      'centros': centros?.map((c) => c.toJson()).toList(),
      'totales': totales,
      'llamadas_por_hora': llamadasPorHora?.map((l) => l.toJson()).toList(),
      'top_agentes': topAgentes?.map((t) => t.toJson()).toList(),
    };
  }
}

/// Modelo KPI de Equipo (para vista de coordinador)
class EquipoKPIModel {
  final int equipoId;
  final String equipoNombre;
  final String? campanaNombre;
  final int totalAgentes;
  final int agentesDisponibles;
  final int agentesEnLlamada;
  final int agentesPostcall;
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion;
  final int tiempoPromedioLlamadaSegundos;
  final String tiempoPromedioLlamadaFormateado;

  EquipoKPIModel({
    required this.equipoId,
    required this.equipoNombre,
    this.campanaNombre,
    required this.totalAgentes,
    required this.agentesDisponibles,
    required this.agentesEnLlamada,
    required this.agentesPostcall,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
    required this.tiempoPromedioLlamadaSegundos,
    required this.tiempoPromedioLlamadaFormateado,
  });

  factory EquipoKPIModel.fromJson(Map<String, dynamic> json) {
    return EquipoKPIModel(
      equipoId: json['equipo_id'] ?? 0,
      equipoNombre: json['equipo_nombre'] ?? '',
      campanaNombre: json['campana_nombre'],
      totalAgentes: json['total_agentes'] ?? 0,
      agentesDisponibles: json['agentes_disponibles'] ?? 0,
      agentesEnLlamada: json['agentes_en_llamada'] ?? 0,
      agentesPostcall: json['agentes_postcall'] ?? 0,
      totalLlamadas: json['total_llamadas'] ?? 0,
      ventasRealizadas: json['ventas_realizadas'] ?? 0,
      tasaConversion: (json['tasa_conversion'] ?? 0.0).toDouble(),
      tiempoPromedioLlamadaSegundos: json['tiempo_promedio_llamada_segundos'] ?? 0,
      tiempoPromedioLlamadaFormateado: json['tiempo_promedio_llamada_formateado'] ?? '00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipo_id': equipoId,
      'equipo_nombre': equipoNombre,
      'campana_nombre': campanaNombre,
      'total_agentes': totalAgentes,
      'agentes_disponibles': agentesDisponibles,
      'agentes_en_llamada': agentesEnLlamada,
      'agentes_postcall': agentesPostcall,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
      'tiempo_promedio_llamada_segundos': tiempoPromedioLlamadaSegundos,
      'tiempo_promedio_llamada_formateado': tiempoPromedioLlamadaFormateado,
    };
  }

  /// Porcentaje de agentes disponibles
  double get porcentajeDisponibles => 
    totalAgentes > 0 ? (agentesDisponibles / totalAgentes) * 100 : 0.0;

  /// Porcentaje de agentes en llamada
  double get porcentajeEnLlamada => 
    totalAgentes > 0 ? (agentesEnLlamada / totalAgentes) * 100 : 0.0;
}

/// Modelo KPI de Campaña (para vista de jefe de campaña)
class CampanaKPIModel {
  final int campanaId;
  final String campanaNombre;
  final String estadoCampana;
  final int? objetivoLlamadas;
  final int? objetivoVentas;
  final int totalEquipos;
  final int totalAgentes;
  final int agentesDisponibles;
  final int agentesEnLlamada;
  final int agentesOtrosEstados;
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion;
  final double? progresoLlamadasPorcentaje;
  final double? progresoVentasPorcentaje;
  final List<EquipoResumenModel>? equipos;

  CampanaKPIModel({
    required this.campanaId,
    required this.campanaNombre,
    required this.estadoCampana,
    this.objetivoLlamadas,
    this.objetivoVentas,
    required this.totalEquipos,
    required this.totalAgentes,
    required this.agentesDisponibles,
    required this.agentesEnLlamada,
    required this.agentesOtrosEstados,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
    this.progresoLlamadasPorcentaje,
    this.progresoVentasPorcentaje,
    this.equipos,
  });

  factory CampanaKPIModel.fromJson(Map<String, dynamic> json) {
    return CampanaKPIModel(
      campanaId: json['campana_id'] ?? 0,
      campanaNombre: json['campana_nombre'] ?? '',
      estadoCampana: json['estado_campana'] ?? '',
      objetivoLlamadas: json['objetivo_llamadas'],
      objetivoVentas: json['objetivo_ventas'],
      totalEquipos: json['total_equipos'] ?? 0,
      totalAgentes: json['total_agentes'] ?? 0,
      agentesDisponibles: json['agentes_disponibles'] ?? 0,
      agentesEnLlamada: json['agentes_en_llamada'] ?? 0,
      agentesOtrosEstados: json['agentes_otros_estados'] ?? 0,
      totalLlamadas: json['total_llamadas'] ?? 0,
      ventasRealizadas: json['ventas_realizadas'] ?? 0,
      tasaConversion: (json['tasa_conversion'] ?? 0.0).toDouble(),
      progresoLlamadasPorcentaje: json['progreso_llamadas_porcentaje']?.toDouble(),
      progresoVentasPorcentaje: json['progreso_ventas_porcentaje']?.toDouble(),
      equipos: (json['equipos'] as List<dynamic>?)
          ?.map((e) => EquipoResumenModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campana_id': campanaId,
      'campana_nombre': campanaNombre,
      'estado_campana': estadoCampana,
      'objetivo_llamadas': objetivoLlamadas,
      'objetivo_ventas': objetivoVentas,
      'total_equipos': totalEquipos,
      'total_agentes': totalAgentes,
      'agentes_disponibles': agentesDisponibles,
      'agentes_en_llamada': agentesEnLlamada,
      'agentes_otros_estados': agentesOtrosEstados,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
      'progreso_llamadas_porcentaje': progresoLlamadasPorcentaje,
      'progreso_ventas_porcentaje': progresoVentasPorcentaje,
      'equipos': equipos?.map((e) => e.toJson()).toList(),
    };
  }

  /// Verifica si la campaña cumple objetivo de llamadas
  bool get cumpleObjetivoLlamadas => 
    progresoLlamadasPorcentaje != null && progresoLlamadasPorcentaje! >= 100.0;

  /// Verifica si la campaña cumple objetivo de ventas
  bool get cumpleObjetivoVentas => 
    progresoVentasPorcentaje != null && progresoVentasPorcentaje! >= 100.0;
}

/// Modelo resumen de equipo (usado en CampanaKPIModel)
class EquipoResumenModel {
  final int equipoId;
  final String equipoNombre;
  final String? coordinadorNombre;
  final int totalAgentes;
  final int totalLlamadas;
  final int ventasRealizadas;

  EquipoResumenModel({
    required this.equipoId,
    required this.equipoNombre,
    this.coordinadorNombre,
    required this.totalAgentes,
    required this.totalLlamadas,
    required this.ventasRealizadas,
  });

  factory EquipoResumenModel.fromJson(Map<String, dynamic> json) {
    return EquipoResumenModel(
      equipoId: json['equipo_id'] ?? 0,
      equipoNombre: json['equipo_nombre'] ?? '',
      coordinadorNombre: json['coordinador_nombre'],
      totalAgentes: json['total_agentes'] ?? 0,
      totalLlamadas: json['total_llamadas'] ?? 0,
      ventasRealizadas: json['ventas_realizadas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipo_id': equipoId,
      'equipo_nombre': equipoNombre,
      'coordinador_nombre': coordinadorNombre,
      'total_agentes': totalAgentes,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
    };
  }
}

/// Modelo KPI de Centro (para vista admin/backoffice)
class CentroKPIModel {
  final int centroId;
  final String centroNombre;
  final String? jefeCentroNombre;
  final int totalCampanas;
  final int totalEquipos;
  final int totalAgentes;
  final int agentesDisponibles;
  final int agentesEnLlamada;
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion;

  CentroKPIModel({
    required this.centroId,
    required this.centroNombre,
    this.jefeCentroNombre,
    required this.totalCampanas,
    required this.totalEquipos,
    required this.totalAgentes,
    required this.agentesDisponibles,
    required this.agentesEnLlamada,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
  });

  factory CentroKPIModel.fromJson(Map<String, dynamic> json) {
    return CentroKPIModel(
      centroId: json['centro_id'] ?? 0,
      centroNombre: json['centro_nombre'] ?? '',
      jefeCentroNombre: json['jefe_centro_nombre'],
      totalCampanas: json['total_campanas'] ?? 0,
      totalEquipos: json['total_equipos'] ?? 0,
      totalAgentes: json['total_agentes'] ?? 0,
      agentesDisponibles: json['agentes_disponibles'] ?? 0,
      agentesEnLlamada: json['agentes_en_llamada'] ?? 0,
      totalLlamadas: json['total_llamadas'] ?? 0,
      ventasRealizadas: json['ventas_realizadas'] ?? 0,
      tasaConversion: (json['tasa_conversion'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centro_id': centroId,
      'centro_nombre': centroNombre,
      'jefe_centro_nombre': jefeCentroNombre,
      'total_campanas': totalCampanas,
      'total_equipos': totalEquipos,
      'total_agentes': totalAgentes,
      'agentes_disponibles': agentesDisponibles,
      'agentes_en_llamada': agentesEnLlamada,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
    };
  }
}

/// Modelo para top agentes
class TopAgenteModel {
  final String agenteId;
  final String agenteNombre;
  final int totalLlamadas;
  final int ventasRealizadas;
  final double tasaConversion;

  TopAgenteModel({
    required this.agenteId,
    required this.agenteNombre,
    required this.totalLlamadas,
    required this.ventasRealizadas,
    required this.tasaConversion,
  });

  factory TopAgenteModel.fromJson(Map<String, dynamic> json) {
    return TopAgenteModel(
      agenteId: json['agente_id'] ?? '',
      agenteNombre: json['agente_nombre'] ?? '',
      totalLlamadas: json['total_llamadas'] ?? 0,
      ventasRealizadas: json['ventas_realizadas'] ?? 0,
      tasaConversion: (json['tasa_conversion'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agente_id': agenteId,
      'agente_nombre': agenteNombre,
      'total_llamadas': totalLlamadas,
      'ventas_realizadas': ventasRealizadas,
      'tasa_conversion': tasaConversion,
    };
  }
}
```

---

## 📝 Notas Importantes

### 1. Rango de Fechas
El sistema soporta diferentes rangos predefinidos:
- `hoy`: Solo el día actual
- `semana`: Últimos 7 días
- `mes`: Últimos 30 días
- `personalizado`: Usar fecha_desde y fecha_hasta

### 2. Actualización en Tiempo Real
Para dashboards en tiempo real, se recomienda:
- Hacer polling cada 30 segundos al endpoint `/overview/`
- Usar WebSockets si está disponible (futuro)
- Cachear datos localmente y mostrar timestamp de última actualización

### 3. Visualización de Datos
Los modelos incluyen datos listos para gráficas:
- `llamadasPorHora`: Para gráfica de barras/líneas
- `estadosDelDia`: Para gráfica de torta/dona
- `topAgentes`: Para tabla de ranking

---

## 🎨 Ejemplos de Uso con BLoC

```dart
/// Event para cargar KPIs
class LoadKPIOverview extends KPIEvent {
  final String rango;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  LoadKPIOverview({
    this.rango = 'hoy',
    this.fechaDesde,
    this.fechaHasta,
  });
}

/// BLoC de KPIs
class KPIBloc extends Bloc<KPIEvent, KPIState> {
  final KPIRepository kpiRepository;
  Timer? _refreshTimer;

  KPIBloc({required this.kpiRepository}) : super(KPIInitial()) {
    on<LoadKPIOverview>(_onLoadKPIOverview);
    on<RefreshKPI>(_onRefreshKPI);
  }

  Future<void> _onLoadKPIOverview(
    LoadKPIOverview event,
    Emitter<KPIState> emit,
  ) async {
    try {
      emit(KPILoading());
      
      final kpis = await kpiRepository.getOverview(
        rango: event.rango,
        fechaDesde: event.fechaDesde,
        fechaHasta: event.fechaHasta,
      );
      
      emit(KPILoaded(kpis: kpis));
      
      // Iniciar auto-refresh cada 30 segundos
      _startAutoRefresh();
    } catch (e) {
      emit(KPIError(message: e.toString()));
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(seconds: 30),
      (_) => add(RefreshKPI()),
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
```

---

**Siguiente:** [00_README.md](./00_README.md) (Índice general)
