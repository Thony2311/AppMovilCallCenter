import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario_model.dart';

/// Clase singleton para gestionar la sesión del usuario con JWT
/// Almacena tokens (access y refresh) y datos del usuario después del login
class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  
  factory AuthManager() {
    return _instance;
  }
  
  AuthManager._internal();

  // Almacenamiento seguro para el refresh token
  final _secureStorage = const FlutterSecureStorage();
  
  // Claves para el almacenamiento seguro
  static const String _refreshTokenKey = 'refresh_token';
  
  // Access token (en memoria, válido 8 horas)
  String? _accessToken;
  
  // Datos del usuario
  UsuarioModel? _user;

  /// Guardar datos de sesión después del login exitoso
  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required UsuarioModel user,
  }) async {
    _accessToken = accessToken;
    _user = user;
    
    // Guardar refresh token de forma segura
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Obtener el access token actual (para hacer requests)
  String? get accessToken => _accessToken;

  /// Obtener el usuario actual
  UsuarioModel? get user => _user;

  /// Obtener el refresh token de forma segura
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Actualizar solo el access token (después de refresh)
  void updateAccessToken(String newAccessToken) {
    _accessToken = newAccessToken;
  }

  /// Actualizar ambos tokens (después de refresh que retorna ambos)
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  /// Verificar si hay una sesión activa
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty && _user != null;

  /// Obtener datos del usuario (retrocompatibilidad)
  String? get email => _user?.email;
  String? get fullName => _user?.fullName;
  String? get role => _user?.role;
  String? get documentoId => _user?.documentoId;
  
  @Deprecated('Usar email en su lugar')
  String? get username => _user?.email;
  
  @Deprecated('Usar fullName en su lugar')
  String? get nombre => _user?.fullName;

  /// Limpiar la sesión (logout)
  Future<void> clearSession() async {
    _accessToken = null;
    _user = null;
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Obtener todos los datos de sesión
  Future<Map<String, dynamic>> getSessionData() async {
    return {
      'accessToken': _accessToken,
      'refreshToken': await getRefreshToken(),
      'user': _user?.toJson(),
      'isAuthenticated': isAuthenticated,
    };
  }

  /// Verificar si el usuario tiene un rol específico
  bool hasRole(String role) {
    return _user?.role.toUpperCase() == role.toUpperCase();
  }

  /// Verificar si el usuario es agente
  bool get isAgent => _user?.isAgent ?? false;

  /// Verificar si el usuario es coordinador
  bool get isCoordinator => _user?.isCoordinator ?? false;

  /// Verificar si el usuario es jefe de campaña
  bool get isJefeCampana => _user?.isJefeCampana ?? false;

  /// Verificar si el usuario es backoffice
  bool get isBackoffice => _user?.isBackoffice ?? false;

  /// Verificar si el usuario es admin
  bool get isAdmin => _user?.isAdmin ?? false;
}
