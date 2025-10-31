/// Modelo simplificado de agente
/// 
/// Usado en contextos donde se lista agentes dentro de un equipo
/// sin necesidad de toda la información del usuario completo.
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
      documentoId: json['documento_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      codigoAgente: json['codigo_agente']?.toString(),
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

  /// Obtiene las iniciales del nombre
  String get iniciales {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  @override
  String toString() => 'AgenteSimpleModel(doc: $documentoId, nombre: $fullName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgenteSimpleModel &&
          runtimeType == other.runtimeType &&
          documentoId == other.documentoId;

  @override
  int get hashCode => documentoId.hashCode;
}
