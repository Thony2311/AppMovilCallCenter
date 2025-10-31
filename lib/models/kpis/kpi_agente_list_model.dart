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
      id: json['id']?.toString() ?? '',
      nombreCompleto: json['nombre_completo']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      estadoActual: json['estado_actual']?.toString() ?? 'DESCONECTADO',
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
  bool get isDisponible => estadoActual.toUpperCase() == 'DISPONIBLE';

  /// Verifica si el agente está en llamada
  bool get isEnLlamada => estadoActual.toUpperCase() == 'EN_LLAMADA';

  /// Verifica si el agente está en postcall
  bool get isPostcall => estadoActual.toUpperCase() == 'POSTCALL';

  /// Verifica si el agente está desconectado
  bool get isDesconectado => estadoActual.toUpperCase() == 'DESCONECTADO';
}
