import 'dart:async';
import '../models/usuario_model.dart';

class LoginApi {
  Future<UsuarioModel?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simula red

    if (username.isEmpty || password.isEmpty) {
      return null;
    }

    // Simulación: solo busca si tiene agente/backoffice en el username
    final role = username.toLowerCase().contains("agente")
        ? "agente"
        : "backoffice";

    return UsuarioModel(
      username: username,
      role: role,
      contrasena: "mock_token_12345",
    );
  }
}
