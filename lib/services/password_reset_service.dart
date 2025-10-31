import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/password_reset_models.dart';
import '../config/api_config.dart';
import '../utils/app_logger.dart';

/// Servicio para manejar la recuperación de contraseña
class PasswordResetService {
  
  /// Solicita un token de recuperación de contraseña
  /// Se enviará un email al usuario con el token
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final model = PasswordResetRequestModel(email: email);
      final body = jsonEncode(model.toJson());

      final response = await http
          .post(
            Uri.parse(ApiConfig.passwordResetRequestEndpoint),
            headers: ApiConfig.headers(),
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData;
      } else {
        throw Exception('Error al solicitar recuperación: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      AppLogger.error('Error en requestPasswordReset: $e', name: 'PasswordResetService');
      rethrow;
    }
  }

  /// Valida si un token de recuperación es válido
  Future<bool> validateToken(String token) async {
    try {
      final model = PasswordResetValidateModel(token: token);
      final body = jsonEncode(model.toJson());

      final response = await http
          .post(
            Uri.parse(ApiConfig.passwordResetValidateEndpoint),
            headers: ApiConfig.headers(),
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData['valid'] == true;
      } else {
        return false;
      }
    } catch (e) {
      AppLogger.error('Error en validateToken: $e', name: 'PasswordResetService');
      return false;
    }
  }

  /// Confirma el cambio de contraseña con el token
  Future<bool> confirmPasswordReset({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final model = PasswordResetConfirmModel(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      // Validaciones locales
      if (!model.isValid) {
        if (!model.passwordsMatch) {
          throw Exception('Las contraseñas no coinciden');
        }
        if (!model.isValidLength) {
          throw Exception('La contraseña debe tener entre 8 y 16 caracteres');
        }
      }

      final body = jsonEncode(model.toJson());

      final response = await http
          .post(
            Uri.parse(ApiConfig.passwordResetConfirmEndpoint),
            headers: ApiConfig.headers(),
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = jsonData['message'] ?? jsonData['error'] ?? 'Error al cambiar contraseña';
        throw Exception(errorMsg);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      AppLogger.error('Error en confirmPasswordReset: $e', name: 'PasswordResetService');
      rethrow;
    }
  }
}
