class UsuarioModel {
  final String username;
  final String role; 
  final String contrasena;
  final int? id;
  final String? email;
  final String? nombre;

  UsuarioModel({
    required this.username,
    required this.role,
    required this.contrasena,
    this.id,
    this.email,
    this.nombre,
  });

  /// Parsea la respuesta JSON de la API
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: (json['id'] is int) ? json['id'] as int : (int.tryParse('${json['id']}')),
  username: _asString(json['username'] ?? json['usuario'] ?? '') ?? '',
  role: _asString(json['role'] ?? json['rol'] ?? json['tipo'] ?? '') ?? '',
  contrasena: _asString(json['token'] ?? json['access_token'] ?? '') ?? '',
  email: _asString(json['email']),
  nombre: _asString(json['nombre'] ?? json['name']),
    );
  }

  // Helper interno para convertir a String de forma segura
  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }

  /// Convierte el modelo a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'token': contrasena,
      'email': email,
      'nombre': nombre,
    };
  }
}
