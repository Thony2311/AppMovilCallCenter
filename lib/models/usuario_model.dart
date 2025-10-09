class UsuarioModel {
  final String username;
  final String role; 
  final String contrasena;

  UsuarioModel({
    required this.username,
    required this.role,
    required this.contrasena,
  });

  // Simula parseo de un JSON 
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      contrasena: json['token'] ?? '',
    );
  }
}
