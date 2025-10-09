class UsuarioModel {
  final String username;
  final String role; // "agente" o "backoffice"
  final String contrasena; // En caso de conexión futura con backend

  UsuarioModel({
    required this.username,
    required this.role,
    required this.contrasena,
  });

  // Simula parseo de un JSON (para futura API real)
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      contrasena: json['token'] ?? '',
    );
  }
}
