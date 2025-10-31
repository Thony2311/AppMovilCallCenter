/// Modelo para los tokens JWT de autenticación
///
/// El sistema usa JWT con dos tipos de tokens:
/// - Access Token: Válido por 8 horas, usado para autenticar requests
/// - Refresh Token: Válido por 7 días, usado para obtener nuevos access tokens
class AuthTokensModel {
  /// Token de acceso (válido por 8 horas)
  final String accessToken;
  
  /// Token de refresco (válido por 7 días)
  final String refreshToken;

  AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  /// Factory constructor para crear desde JSON
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: (json['access'] ?? '') as String,
      refreshToken: (json['refresh'] ?? '') as String,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
    };
  }

  /// Verifica si los tokens están vacíos
  bool get isEmpty => accessToken.isEmpty || refreshToken.isEmpty;

  /// Verifica si los tokens están completos
  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;
}
