import 'usuario_model.dart';
import 'auth_tokens_model.dart';

/// Modelo para la respuesta completa del login
///
/// Combina la información del usuario y los tokens JWT
class LoginResponseModel {
  /// Información del usuario autenticado
  final UsuarioModel user;
  
  /// Tokens JWT (access y refresh)
  final AuthTokensModel tokens;

  LoginResponseModel({
    required this.user,
    required this.tokens,
  });

  /// Factory constructor para crear desde JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UsuarioModel.fromJson((json['user'] ?? {}) as Map<String, dynamic>),
      tokens: AuthTokensModel.fromJson((json['tokens'] ?? {}) as Map<String, dynamic>),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}
