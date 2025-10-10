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
      id: json['id'] as int?,
      username: json['username'] ?? json['usuario'] ?? '',
      role: json['role'] ?? json['rol'] ?? json['tipo'] ?? '',
      contrasena: json['token'] ?? json['access_token'] ?? '',
      email: json['email'] as String?,
      nombre: json['nombre'] ?? json['name'] as String?,
    );
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
