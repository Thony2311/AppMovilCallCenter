import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';
import '../config/api_config.dart';
import '../utils/app_logger.dart';

class LoginApi {
  /// Realiza el login contra la API en EC2
  /// Retorna el UsuarioModel si es exitoso, null si falla
  Future<UsuarioModel?> login(String username, String password) async {
    try {
      // Validación básica
      if (username.isEmpty || password.isEmpty) {
        return null;
      }

      // Preparar el body de la petición
      final body = jsonEncode({
        'username': username,
        'password': password,
      });

      // Hacer la petición POST a la API
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginEndpoint),
            headers: ApiConfig.headers(),
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      // Verificar el código de respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parsear la respuesta JSON
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Algunos backends envuelven la data en un objeto "data" o "user"
        final userData = jsonData['data'] ?? jsonData['user'] ?? jsonData;
        
        return UsuarioModel.fromJson(userData);
      } else if (response.statusCode == 401) {
        // Credenciales incorrectas
        return null;
      } else {
        // Otro error del servidor
        AppLogger.warn('Error en login: ${response.statusCode} - ${response.body}',
            name: 'LoginApi.login');
        return null;
      }
    } on TimeoutException catch (e) {
      AppLogger.warn('Timeout en login: $e', name: 'LoginApi.login');
      return null;
    } catch (e) {
      AppLogger.error('Error de conexión en login: $e', name: 'LoginApi.login');
      // En desarrollo, puedes descomentar esto para ver el error completo
      // rethrow;
      return null;
    }
  }

  /// Valida si un token sigue siendo válido
  Future<bool> validateToken(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.validateTokenEndpoint),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error validando token: $e', name: 'LoginApi.validateToken');
      return false;
    }
  }

  /// Cierra la sesión del usuario
  Future<bool> logout(String token) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.logoutEndpoint),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      AppLogger.error('Error en logout: $e', name: 'LoginApi.logout');
      return false;
    }
  }
}
