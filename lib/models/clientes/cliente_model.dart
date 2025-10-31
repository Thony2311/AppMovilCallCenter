/// Modelo para representar un cliente de una campaña
/// 
/// Incluye información básica de contacto y datos adicionales
/// almacenados en formato JSON flexible (otros_datos).
class ClienteModel {
  final int clienteId;
  final int campanaId;
  final String nombre;
  final String telefono;
  final int? baseDatosId;

  /// Campos extraídos de otros_datos JSON o directos
  final String? documentoId;
  final String? email;
  final String? direccion;
  final String? observaciones;

  /// Datos adicionales en formato JSON flexible
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
      clienteId: (json['cliente_id'] as num?)?.toInt() ?? 0,
      campanaId: (json['campana'] as num?)?.toInt() ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      baseDatosId: (json['base_datos'] as num?)?.toInt(),
      documentoId: json['documento_id']?.toString(),
      email: json['email']?.toString(),
      direccion: json['direccion']?.toString(),
      observaciones: json['observaciones']?.toString(),
      otrosDatos: json['otros_datos'] != null
          ? Map<String, dynamic>.from(json['otros_datos'] as Map)
          : null,
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
  bool get isContactable =>
      telefono.isNotEmpty || (email != null && email!.isNotEmpty);

  /// Obtiene un valor del campo otros_datos por clave
  dynamic getOtroDato(String key) {
    return otrosDatos?[key];
  }

  /// Verifica si tiene un dato adicional específico
  bool hasOtroDato(String key) {
    return otrosDatos?.containsKey(key) ?? false;
  }

  /// Obtiene una representación de texto del teléfono formateado
  String get telefonoFormateado {
    if (telefono.isEmpty) return 'Sin teléfono';
    // Si ya tiene formato, retornarlo
    if (telefono.contains('+')) return telefono;
    // Intenta formatear números colombianos
    if (telefono.length == 10) {
      return '+57 ${telefono.substring(0, 3)} ${telefono.substring(3, 6)} ${telefono.substring(6)}';
    }
    return telefono;
  }

  @override
  String toString() =>
      'ClienteModel(id: $clienteId, nombre: $nombre, telefono: $telefono)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClienteModel &&
          runtimeType == other.runtimeType &&
          clienteId == other.clienteId;

  @override
  int get hashCode => clienteId.hashCode;
}
