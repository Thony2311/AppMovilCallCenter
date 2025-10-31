/// Modelo para representar una campaña del call center
/// 
/// Representa toda la información de una campaña incluyendo
/// sus objetivos, estado actual y relaciones con centro y jefe.
class CampanaModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int estadoId;
  final String estadoNombre;
  final int? objetivoLlamadas;
  final int? objetivoVentas;
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
    this.objetivoVentas,
    this.jefeCampanaId,
    this.centroId,
    this.centroNombre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampanaModel.fromJson(Map<String, dynamic> json) {
    return CampanaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'].toString())
          : DateTime.now(),
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'].toString())
          : null,
      estadoId: (json['estado'] as num?)?.toInt() ?? 0,
      estadoNombre: json['estado_nombre']?.toString() ?? '',
      objetivoLlamadas: (json['objetivo_llamadas'] as num?)?.toInt(),
      objetivoVentas: (json['objetivo_ventas'] as num?)?.toInt(),
      jefeCampanaId: json['jefe_campana']?.toString(),
      centroId: (json['centro'] as num?)?.toInt(),
      centroNombre: json['centro_nombre']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
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
      'objetivo_ventas': objetivoVentas,
      'jefe_campana': jefeCampanaId,
      'centro': centroId,
      'centro_nombre': centroNombre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Verifica si la campaña está activa
  bool get isActiva => estadoNombre.toUpperCase() == 'ACTIVA';

  /// Verifica si la campaña está pausada
  bool get isPausada => estadoNombre.toUpperCase() == 'PAUSADA';

  /// Verifica si la campaña finalizó
  bool get isFinalizada => estadoNombre.toUpperCase() == 'FINALIZADA';

  /// Obtiene el color asociado al estado de la campaña
  String get colorEstado {
    if (isActiva) return '#4CAF50'; // Verde
    if (isPausada) return '#FF9800'; // Naranja
    if (isFinalizada) return '#9E9E9E'; // Gris
    return '#2196F3'; // Azul por defecto
  }

  /// Verifica si la campaña está en el rango de fechas actual
  bool get isEnRango {
    final now = DateTime.now();
    if (fechaFin == null) {
      return now.isAfter(fechaInicio);
    }
    return now.isAfter(fechaInicio) && now.isBefore(fechaFin!);
  }

  /// Calcula los días restantes de la campaña
  int? get diasRestantes {
    if (fechaFin == null) return null;
    final now = DateTime.now();
    return fechaFin!.difference(now).inDays;
  }

  /// Crea una copia con campos actualizados
  CampanaModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? estadoId,
    String? estadoNombre,
    int? objetivoLlamadas,
    int? objetivoVentas,
    String? jefeCampanaId,
    int? centroId,
    String? centroNombre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampanaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estadoId: estadoId ?? this.estadoId,
      estadoNombre: estadoNombre ?? this.estadoNombre,
      objetivoLlamadas: objetivoLlamadas ?? this.objetivoLlamadas,
      objetivoVentas: objetivoVentas ?? this.objetivoVentas,
      jefeCampanaId: jefeCampanaId ?? this.jefeCampanaId,
      centroId: centroId ?? this.centroId,
      centroNombre: centroNombre ?? this.centroNombre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'CampanaModel(id: $id, nombre: $nombre, estado: $estadoNombre)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampanaModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
