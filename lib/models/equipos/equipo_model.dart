import '../campanas/campana_simple_model.dart';
import 'agente_simple_model.dart';

/// Modelo para representar un equipo de agentes
/// 
/// Contiene información del equipo, su coordinador, campaña asignada
/// y la lista de agentes que lo componen.
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
      equipoId: (json['equipo_id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      centroNombre: json['centro_nombre']?.toString(),
      coordinadorId: json['coordinador']?.toString(),
      coordinadorNombre: json['coordinador_nombre']?.toString(),
      campanaId: (json['campana'] as num?)?.toInt(),
      campanaInfo: json['campana_info'] != null
          ? CampanaSimpleModel.fromJson(json['campana_info'] as Map<String, dynamic>)
          : null,
      agentes: (json['agentes'] as List<dynamic>?)
              ?.map((a) => AgenteSimpleModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      cantidadAgentes: (json['cantidad_agentes'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true,
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

  /// Verifica si el equipo tiene agentes asignados
  bool get tieneAgentes => agentes.isNotEmpty;

  /// Verifica si el equipo tiene una campaña asignada
  bool get tieneCampana => campanaInfo != null;

  /// Verifica si la campaña asignada está activa
  bool get campanaActiva => campanaInfo?.isActiva ?? false;

  /// Obtiene el estado del equipo como texto
  String get estadoTexto {
    if (!isActive) return 'Inactivo';
    if (!tieneCampana) return 'Sin campaña';
    if (campanaActiva) return 'Activo';
    return 'Campaña ${campanaInfo!.estadoNombre}';
  }

  /// Crea una copia con campos actualizados
  EquipoModel copyWith({
    int? equipoId,
    String? nombre,
    String? centroNombre,
    String? coordinadorId,
    String? coordinadorNombre,
    int? campanaId,
    CampanaSimpleModel? campanaInfo,
    List<AgenteSimpleModel>? agentes,
    int? cantidadAgentes,
    bool? isActive,
  }) {
    return EquipoModel(
      equipoId: equipoId ?? this.equipoId,
      nombre: nombre ?? this.nombre,
      centroNombre: centroNombre ?? this.centroNombre,
      coordinadorId: coordinadorId ?? this.coordinadorId,
      coordinadorNombre: coordinadorNombre ?? this.coordinadorNombre,
      campanaId: campanaId ?? this.campanaId,
      campanaInfo: campanaInfo ?? this.campanaInfo,
      agentes: agentes ?? this.agentes,
      cantidadAgentes: cantidadAgentes ?? this.cantidadAgentes,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() => 'EquipoModel(id: $equipoId, nombre: $nombre, agentes: $cantidadAgentes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipoModel &&
          runtimeType == other.runtimeType &&
          equipoId == other.equipoId;

  @override
  int get hashCode => equipoId.hashCode;
}
