/// Modelo simplificado de campaña
/// 
/// Usado en contextos donde no se necesita toda la información,
/// como en la lista de equipos o referencias rápidas.
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
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      estadoId: (json['estado'] as num?)?.toInt() ?? 0,
      estadoNombre: json['estado_nombre']?.toString() ?? '',
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'].toString())
          : DateTime.now(),
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'].toString())
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

  /// Verifica si la campaña está activa
  bool get isActiva => estadoNombre.toUpperCase() == 'ACTIVA';

  /// Verifica si la campaña está pausada
  bool get isPausada => estadoNombre.toUpperCase() == 'PAUSADA';

  /// Verifica si la campaña finalizó
  bool get isFinalizada => estadoNombre.toUpperCase() == 'FINALIZADA';

  @override
  String toString() => 'CampanaSimpleModel(id: $id, nombre: $nombre)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampanaSimpleModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
