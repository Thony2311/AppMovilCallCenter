import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response_model.dart';
import '../models/auth_tokens_model.dart';
import '../config/api_config.dart';
import '../utils/app_logger.dart';

/// Servicio para manejar la autenticación JWT con el backend
class LoginApi {
  /// Realiza el login contra el backend
  /// Retorna LoginResponseModel (user + tokens) si es exitoso
  /// Lanza excepción si falla
  Future<LoginResponseModel> login(String email, String password) async {
    try {
      // Validación básica
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email y contraseña son requeridos');
      }

      // Preparar el body de la petición (email en vez de username)
      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      AppLogger.info('Intentando login con email: $email', name: 'LoginApi.login');

      // Hacer la petición POST a la API
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginEndpoint),
            headers: ApiConfig.headers(),
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      AppLogger.info('Respuesta login: ${response.statusCode}', name: 'LoginApi.login');

      // Verificar el código de respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parsear la respuesta JSON
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // La respuesta debe tener la estructura {user: {...}, tokens: {...}}
        if (!jsonData.containsKey('user') || !jsonData.containsKey('tokens')) {
          AppLogger.error('Respuesta sin user o tokens: $jsonData', name: 'LoginApi.login');
          throw Exception('Respuesta del servidor en formato incorrecto');
        }

        return LoginResponseModel.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        // Credenciales incorrectas o usuario desactivado
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = jsonData['non_field_errors']?.first ?? 
                        jsonData['detail'] ?? 
                        'Credenciales incorrectas';
        throw Exception(errorMsg);
      } else if (response.statusCode == 401) {
        throw Exception('Credenciales incorrectas');
      } else {
        // Otro error del servidor
        AppLogger.error('Error en login: ${response.statusCode} - ${response.body}',
            name: 'LoginApi.login');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      AppLogger.error('Timeout en login: $e', name: 'LoginApi.login');
      throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
    } catch (e) {
      AppLogger.error('Error de conexión en login: $e', name: 'LoginApi.login');
      rethrow;
    }
  }

  /// Refresca el access token usando el refresh token
  /// Retorna los nuevos tokens
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    try {
      final body = jsonEncode({'refresh': refreshToken});

      final response = await http
          .post(
            Uri.parse(ApiConfig.refreshTokenEndpoint),
            headers: ApiConfig.headers(),
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokensModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Refresh token expirado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Error al refrescar token: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado al refrescar token');
    } catch (e) {
      AppLogger.error('Error en refreshToken: $e', name: 'LoginApi.refreshToken');
      rethrow;
    }
  }

  /// Cierra la sesión del usuario (invalida el refresh token)
  Future<bool> logout(String refreshToken, String accessToken) async {
    try {
      final body = jsonEncode({'refresh': refreshToken});

      final response = await http
          .post(
            Uri.parse(ApiConfig.logoutEndpoint),
            headers: ApiConfig.headers(token: accessToken),
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      AppLogger.error('Error en logout: $e', name: 'LoginApi.logout');
      // Aunque falle el logout en el servidor, retornamos true
      // para que se limpie la sesión local
      return true;
    }
  }
}
