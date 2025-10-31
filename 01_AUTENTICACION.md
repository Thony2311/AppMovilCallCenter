# Módulo de Autenticación - Flutter

## 📋 Descripción General

Este módulo maneja toda la lógica de autenticación JWT del sistema de call center. Incluye login, logout, refresh de tokens y recuperación de contraseña.

---

## 🔑 Endpoints de Autenticación

### 1. Login
**URL:** `POST /api/auth/login/`  
**Autenticación:** No requerida  
**Descripción:** Autentica al usuario y devuelve tokens JWT

**Request Body:**
```json
{
  "email": "agente@callcenter.com",
  "password": "password123"
}
```

**Response Success (200):**
```json
{
  "user": {
    "documento_id": "1234567890",
    "email": "agente@callcenter.com",
    "first_name": "Juan",
    "last_name": "Pérez",
    "full_name": "Juan Pérez",
    "phone": "+57 300 123 4567",
    "foto_perfil": "https://ejemplo.com/foto.jpg",
    "role": "AGENTE",
    "is_active": true,
    "is_staff": false,
    "is_superuser": false
  },
  "tokens": {
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Errores Posibles:**
- `400 Bad Request`: Credenciales incorrectas o usuario desactivado
```json
{
  "non_field_errors": ["Las credenciales son incorrectas."]
}
```

---

### 2. Logout
**URL:** `POST /api/auth/logout/`  
**Autenticación:** Requerida (Bearer Token)  
**Descripción:** Invalida el refresh token (blacklist)

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response Success (200):**
```json
{
  "message": "Logout exitoso"
}
```

**Errores Posibles:**
- `400 Bad Request`: Token inválido
- `401 Unauthorized`: No autenticado

---

### 3. Refresh Token
**URL:** `POST /api/auth/refresh/`  
**Autenticación:** No requerida (usa refresh token)  
**Descripción:** Obtiene un nuevo access token usando el refresh token

**Request Body:**
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response Success (200):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Errores Posibles:**
- `401 Unauthorized`: Token expirado o inválido

---

### 4. Solicitar Recuperación de Contraseña
**URL:** `POST /api/auth/password-reset/request/`  
**Autenticación:** No requerida  
**Descripción:** Envía un token de recuperación al email del usuario

**Request Body:**
```json
{
  "email": "agente@callcenter.com"
}
```

**Response Success (200):**
```json
{
  "message": "Si el correo existe, recibirás instrucciones para restablecer tu contraseña",
  "token": "abc123def456..."
}
```

---

### 5. Validar Token de Recuperación
**URL:** `POST /api/auth/password-reset/validate-token/`  
**Autenticación:** No requerida  
**Descripción:** Valida si un token de recuperación es válido

**Request Body:**
```json
{
  "token": "abc123def456..."
}
```

**Response Success (200):**
```json
{
  "valid": true,
  "message": "Token válido"
}
```

**Errores Posibles:**
- `400 Bad Request`: Token inválido o expirado

---

### 6. Confirmar Nueva Contraseña
**URL:** `POST /api/auth/password-reset/confirm/`  
**Autenticación:** No requerida  
**Descripción:** Establece una nueva contraseña usando el token

**Request Body:**
```json
{
  "token": "abc123def456...",
  "new_password": "NuevaPassword123!",
  "confirm_password": "NuevaPassword123!"
}
```

**Response Success (200):**
```json
{
  "message": "Contraseña actualizada exitosamente"
}
```

**Errores Posibles:**
- `400 Bad Request`: Contraseñas no coinciden o no cumplen requisitos

---

## 📦 Modelos de Flutter

### 1. User Model
```dart
/// Modelo para representar un usuario autenticado
/// 
/// Este modelo contiene toda la información del usuario que retorna el backend
/// después de un login exitoso.
class UserModel {
  /// Identificador único del usuario (documento de identidad)
  final String documentoId;
  
  /// Correo electrónico del usuario (único en el sistema)
  final String email;
  
  /// Primer nombre del usuario
  final String firstName;
  
  /// Apellido del usuario
  final String lastName;
  
  /// Nombre completo (computed field)
  final String fullName;
  
  /// Número de teléfono (opcional)
  final String? phone;
  
  /// URL de la foto de perfil (opcional)
  final String? fotoPerfil;
  
  /// Rol del usuario en el sistema
  /// Valores posibles: AGENTE, COORDINADOR, JEFE_CAMPANA, BACKOFFICE, ADMIN
  final String role;
  
  /// Indica si el usuario está activo en el sistema
  final bool isActive;
  
  /// Indica si el usuario es staff (tiene acceso al admin)
  final bool isStaff;
  
  /// Indica si el usuario es superusuario
  final bool isSuperuser;

  UserModel({
    required this.documentoId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.phone,
    this.fotoPerfil,
    required this.role,
    required this.isActive,
    required this.isStaff,
    required this.isSuperuser,
  });

  /// Factory constructor para crear un UserModel desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      documentoId: json['documento_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      fotoPerfil: json['foto_perfil'],
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
      isStaff: json['is_staff'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'documento_id': documentoId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'phone': phone,
      'foto_perfil': fotoPerfil,
      'role': role,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
    };
  }

  /// Crea una copia del modelo con algunos campos modificados
  UserModel copyWith({
    String? documentoId,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phone,
    String? fotoPerfil,
    String? role,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
  }) {
    return UserModel(
      documentoId: documentoId ?? this.documentoId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
    );
  }

  /// Verifica si el usuario es agente
  bool get isAgent => role == 'AGENTE';

  /// Verifica si el usuario es coordinador
  bool get isCoordinator => role == 'COORDINADOR';

  /// Verifica si el usuario es jefe de campaña
  bool get isJefeCampana => role == 'JEFE_CAMPANA' || role == 'JEFE DE CAMPAÑA';

  /// Verifica si el usuario es backoffice
  bool get isBackoffice => role == 'BACKOFFICE';

  /// Verifica si el usuario es administrador
  bool get isAdmin => role == 'ADMIN';
}
```

---

### 2. Auth Tokens Model
```dart
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
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',
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
```

---

### 3. Login Response Model
```dart
/// Modelo para la respuesta completa del login
///
/// Combina la información del usuario y los tokens JWT
class LoginResponseModel {
  /// Información del usuario autenticado
  final UserModel user;
  
  /// Tokens JWT (access y refresh)
  final AuthTokensModel tokens;

  LoginResponseModel({
    required this.user,
    required this.tokens,
  });

  /// Factory constructor para crear desde JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      tokens: AuthTokensModel.fromJson(json['tokens'] ?? {}),
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
```

---

### 4. Password Reset Request Model
```dart
/// Modelo para solicitud de recuperación de contraseña
class PasswordResetRequestModel {
  /// Email del usuario que solicita recuperar contraseña
  final String email;

  PasswordResetRequestModel({required this.email});

  /// Convierte el modelo a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}
```

---

### 5. Password Reset Confirm Model
```dart
/// Modelo para confirmar el reseteo de contraseña
class PasswordResetConfirmModel {
  /// Token de recuperación recibido por email
  final String token;
  
  /// Nueva contraseña (8-16 caracteres)
  final String newPassword;
  
  /// Confirmación de la nueva contraseña
  final String confirmPassword;

  PasswordResetConfirmModel({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  /// Convierte el modelo a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }

  /// Valida que las contraseñas coincidan
  bool get passwordsMatch => newPassword == confirmPassword;

  /// Valida que la contraseña cumpla con los requisitos mínimos
  /// - Al menos 8 caracteres
  /// - Máximo 16 caracteres
  bool get isValidLength => 
    newPassword.length >= 8 && newPassword.length <= 16;
}
```

---

## 🔐 Consideraciones de Seguridad

### 1. Almacenamiento de Tokens
- **Access Token**: Almacenar en memoria (estado de la app)
- **Refresh Token**: Almacenar en `flutter_secure_storage`
- **NUNCA** almacenar tokens en `SharedPreferences` sin encriptar

### 2. Interceptor de HTTP
Debes crear un interceptor que:
- Agregue automáticamente el header `Authorization: Bearer <access_token>` a todos los requests
- Maneje la renovación automática de tokens cuando el access token expire
- Redirija al login si el refresh token también expiró

### 3. Manejo de Expiración
- **Access Token**: 8 horas de validez
- **Refresh Token**: 7 días de validez
- Implementar lógica para refrescar el access token antes de que expire

---

## 📝 Ejemplo de Uso con BLoC

```dart
/// Event para iniciar sesión
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

/// State cuando el login es exitoso
class LoginSuccess extends AuthState {
  final LoginResponseModel loginResponse;

  LoginSuccess({required this.loginResponse});
}

/// BLoC de autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final response = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      
      // Guardar tokens de forma segura
      await _secureStorage.write(
        key: 'refresh_token',
        value: response.tokens.refreshToken,
      );
      
      emit(LoginSuccess(loginResponse: response));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  // ... resto de handlers
}
```

---

## 🧪 Casos de Prueba Sugeridos

1. **Login exitoso**: Verificar que se reciban user y tokens
2. **Login fallido**: Credenciales incorrectas
3. **Usuario desactivado**: Cuenta deshabilitada
4. **Refresh token**: Renovar access token antes de expiración
5. **Logout**: Invalidar tokens correctamente
6. **Password reset flow**: Todo el flujo de recuperación

---

## 📚 Recursos Adicionales

- **JWT Info**: Los tokens JWT contienen información del usuario (no sensible)
- **Decode JWT**: Usar `dart:convert` + `base64` para decodificar payload
- **Token Expiry**: Verificar campo `exp` del JWT para saber cuándo expira

---

**Siguiente Módulo:** [02_USUARIOS.md](./02_USUARIOS.md)
