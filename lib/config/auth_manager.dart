/// Clase singleton para gestionar la sesión del usuario
/// Almacena el token y datos del usuario después del login
class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  
  factory AuthManager() {
    return _instance;
  }
  
  AuthManager._internal();

  String? _token;
  String? _username;
  String? _nombre;
  String? _email;
  String? _role;
  int? _userId;

  /// Guardar datos de sesión después del login
  void setSession({
    required String token,
    String? username,
    String? nombre,
    String? email,
    String? role,
    int? userId,
  }) {
    _token = token;
    _username = username;
    _nombre = nombre;
    _email = email;
    _role = role;
    _userId = userId;
  }

  /// Obtener el token actual
  String? get token => _token;

  /// Obtener el username actual
  String? get username => _username;

  /// Obtener el nombre completo del usuario
  String? get nombre => _nombre;

  /// Obtener el email del usuario
  String? get email => _email;

  /// Obtener el rol actual
  String? get role => _role;

  /// Obtener el ID del usuario
  int? get userId => _userId;

  /// Verificar si hay una sesión activa
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Limpiar la sesión (logout)
  void clearSession() {
    _token = null;
    _username = null;
    _nombre = null;
    _email = null;
    _role = null;
    _userId = null;
  }

  /// Obtener todos los datos de sesión
  Map<String, dynamic> getSessionData() {
    return {
      'token': _token,
      'username': _username,
      'role': _role,
      'userId': _userId,
      'isAuthenticated': isAuthenticated,
    };
  }
}
