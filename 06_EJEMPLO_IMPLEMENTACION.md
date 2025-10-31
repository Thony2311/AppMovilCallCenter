# 💡 Ejemplo Completo de Implementación - Módulo de Autenticación

Este archivo muestra un ejemplo completo de cómo implementar el módulo de autenticación siguiendo la arquitectura BLoC.

---

## 📁 Estructura de Archivos

```
lib/
├── data/
│   ├── models/
│   │   └── auth/
│   │       ├── user_model.dart
│   │       ├── auth_tokens_model.dart
│   │       └── login_response_model.dart
│   ├── datasources/
│   │   └── auth_remote_datasource.dart
│   └── repositories/
│       └── auth_repository.dart
├── presentation/
│   ├── blocs/
│   │   └── auth/
│   │       ├── auth_bloc.dart
│   │       ├── auth_event.dart
│   │       └── auth_state.dart
│   └── pages/
│       └── auth/
│           └── login_page.dart
└── core/
    ├── api/
    │   └── api_client.dart
    └── constants/
        └── api_constants.dart
```

---

## 1️⃣ Constants

### `lib/core/constants/api_constants.dart`
```dart
/// Constantes de la API
class ApiConstants {
  // URL base del backend
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000;
  
  // Endpoints de autenticación
  static const String loginEndpoint = '/auth/login/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String refreshEndpoint = '/auth/refresh/';
  static const String passwordResetRequestEndpoint = '/auth/password-reset/request/';
  static const String passwordResetConfirmEndpoint = '/auth/password-reset/confirm/';
  
  // Keys de storage
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
```

---

## 2️⃣ Models

### `lib/data/models/auth/user_model.dart`
```dart
import 'package:equatable/equatable.dart';

/// Modelo de usuario autenticado
/// 
/// Este modelo representa los datos del usuario que retorna el backend
/// después de un login exitoso.
class UserModel extends Equatable {
  final String documentoId;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? phone;
  final String? fotoPerfil;
  final String role;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;

  const UserModel({
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

  /// Factory constructor para crear desde JSON del backend
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

  /// Convierte el modelo a JSON para storage local
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

  /// Crea una copia con campos modificados
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

  // Getters para verificar roles
  bool get isAgent => role == 'AGENTE';
  bool get isCoordinator => role == 'COORDINADOR';
  bool get isJefeCampana => role == 'JEFE_CAMPANA' || role == 'JEFE DE CAMPAÑA';
  bool get isBackoffice => role == 'BACKOFFICE';
  bool get isAdmin => role == 'ADMIN';

  @override
  List<Object?> get props => [
        documentoId,
        email,
        firstName,
        lastName,
        fullName,
        phone,
        fotoPerfil,
        role,
        isActive,
        isStaff,
        isSuperuser,
      ];
}
```

### `lib/data/models/auth/auth_tokens_model.dart`
```dart
import 'package:equatable/equatable.dart';

/// Modelo para tokens JWT
class AuthTokensModel extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
    };
  }

  bool get isEmpty => accessToken.isEmpty || refreshToken.isEmpty;
  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
```

### `lib/data/models/auth/login_response_model.dart`
```dart
import 'package:equatable/equatable.dart';
import 'user_model.dart';
import 'auth_tokens_model.dart';

/// Modelo para la respuesta completa del login
class LoginResponseModel extends Equatable {
  final UserModel user;
  final AuthTokensModel tokens;

  const LoginResponseModel({
    required this.user,
    required this.tokens,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      tokens: AuthTokensModel.fromJson(json['tokens'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
    };
  }

  @override
  List<Object?> get props => [user, tokens];
}
```

---

## 3️⃣ Data Source

### `lib/data/datasources/auth_remote_datasource.dart`
```dart
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth/login_response_model.dart';

/// Data source para operaciones de autenticación con el backend
class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource({required this.dio});

  /// Realiza login en el backend
  /// 
  /// Throws [DioException] si hay error de red o del servidor
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Login failed with status: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}',
        ),
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Realiza logout invalidando el refresh token
  /// 
  /// [refreshToken] es el refresh token a invalidar
  Future<void> logout({required String refreshToken}) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Logout failed with status: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  /// Refresca el access token usando el refresh token
  /// 
  /// Returns nuevo [AuthTokensModel] con tokens actualizados
  Future<AuthTokensModel> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshEndpoint}',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        return AuthTokensModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Token refresh failed with status: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    }
  }
}
```

---

## 4️⃣ Repository

### `lib/data/repositories/auth_repository.dart`
```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../datasources/auth_remote_datasource.dart';
import '../models/auth/login_response_model.dart';
import '../models/auth/user_model.dart';
import '../models/auth/auth_tokens_model.dart';
import '../../core/constants/api_constants.dart';

/// Posibles fallos en operaciones de autenticación
abstract class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

class ServerFailure extends AuthFailure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure(String message) : super(message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Credenciales incorrectas');
}

class UnknownFailure extends AuthFailure {
  const UnknownFailure(String message) : super(message);
}

/// Repositorio para operaciones de autenticación
/// 
/// Maneja la lógica de negocio de autenticación, storage de tokens
/// y gestión de sesión de usuario.
class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepository({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  /// Realiza login y guarda tokens de forma segura
  /// 
  /// Returns [Right] con [LoginResponseModel] si es exitoso
  /// Returns [Left] con [AuthFailure] si falla
  Future<Either<AuthFailure, LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Guardar tokens de forma segura
      await secureStorage.write(
        key: ApiConstants.accessTokenKey,
        value: response.tokens.accessToken,
      );
      await secureStorage.write(
        key: ApiConstants.refreshTokenKey,
        value: response.tokens.refreshToken,
      );

      // Guardar datos de usuario
      await secureStorage.write(
        key: ApiConstants.userDataKey,
        value: jsonEncode(response.user.toJson()),
      );

      return Right(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return const Left(InvalidCredentialsFailure());
      } else if (e.response?.statusCode != null) {
        return Left(ServerFailure(
          e.response?.data['detail'] ?? 'Error del servidor',
        ));
      } else {
        return Left(NetworkFailure(
          'Error de conexión: ${e.message}',
        ));
      }
    } catch (e) {
      return Left(UnknownFailure('Error inesperado: $e'));
    }
  }

  /// Realiza logout y limpia storage
  Future<Either<AuthFailure, void>> logout() async {
    try {
      // Obtener refresh token
      final refreshToken = await secureStorage.read(
        key: ApiConstants.refreshTokenKey,
      );

      if (refreshToken != null) {
        // Invalidar token en el backend
        await remoteDataSource.logout(refreshToken: refreshToken);
      }

      // Limpiar storage local
      await secureStorage.delete(key: ApiConstants.accessTokenKey);
      await secureStorage.delete(key: ApiConstants.refreshTokenKey);
      await secureStorage.delete(key: ApiConstants.userDataKey);

      return const Right(null);
    } catch (e) {
      // Aunque falle el logout en backend, limpiar local
      await secureStorage.delete(key: ApiConstants.accessTokenKey);
      await secureStorage.delete(key: ApiConstants.refreshTokenKey);
      await secureStorage.delete(key: ApiConstants.userDataKey);

      return const Right(null);
    }
  }

  /// Verifica si el usuario tiene sesión activa
  Future<bool> isLoggedIn() async {
    final accessToken = await secureStorage.read(
      key: ApiConstants.accessTokenKey,
    );
    final refreshToken = await secureStorage.read(
      key: ApiConstants.refreshTokenKey,
    );

    return accessToken != null && refreshToken != null;
  }

  /// Obtiene el usuario guardado localmente
  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = await secureStorage.read(
        key: ApiConstants.userDataKey,
      );

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Refresca el access token
  Future<Either<AuthFailure, AuthTokensModel>> refreshAccessToken() async {
    try {
      final refreshToken = await secureStorage.read(
        key: ApiConstants.refreshTokenKey,
      );

      if (refreshToken == null) {
        return const Left(InvalidCredentialsFailure());
      }

      final newTokens = await remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );

      // Guardar nuevos tokens
      await secureStorage.write(
        key: ApiConstants.accessTokenKey,
        value: newTokens.accessToken,
      );
      await secureStorage.write(
        key: ApiConstants.refreshTokenKey,
        value: newTokens.refreshToken,
      );

      return Right(newTokens);
    } catch (e) {
      return Left(UnknownFailure('Error al refrescar token: $e'));
    }
  }
}
```

---

## 5️⃣ BLoC - Events

### `lib/presentation/blocs/auth/auth_event.dart`
```dart
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para iniciar sesión
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Evento para cerrar sesión
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Evento para verificar si hay sesión activa
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Evento para refrescar token
class RefreshTokenRequested extends AuthEvent {
  const RefreshTokenRequested();
}
```

---

## 6️⃣ BLoC - States

### `lib/presentation/blocs/auth/auth_state.dart`
```dart
import 'package:equatable/equatable.dart';
import '../../../data/models/auth/user_model.dart';

/// Estados del BLoC de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga (login en progreso)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado autenticado (usuario logueado)
class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Estado no autenticado (sin sesión)
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Estado de error
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

---

## 7️⃣ BLoC

### `lib/presentation/blocs/auth/auth_bloc.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../data/repositories/auth_repository.dart';

/// BLoC para gestión de autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    // Registrar handlers de eventos
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
  }

  /// Handler para evento de login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Emitir estado de carga
    emit(const AuthLoading());

    // Intentar login
    final result = await authRepository.login(
      email: event.email,
      password: event.password,
    );

    // Manejar resultado
    result.fold(
      // En caso de error
      (failure) => emit(AuthError(message: failure.message)),
      // En caso de éxito
      (loginResponse) => emit(Authenticated(user: loginResponse.user)),
    );
  }

  /// Handler para evento de logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    await authRepository.logout();

    emit(const Unauthenticated());
  }

  /// Handler para verificar estado de autenticación
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      final user = await authRepository.getCurrentUser();

      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } else {
      emit(const Unauthenticated());
    }
  }

  /// Handler para refrescar token
  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.refreshAccessToken();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) {
        // Token refrescado exitosamente, mantener estado autenticado
        // No hacemos nada aquí, el estado ya es Authenticated
      },
    );
  }
}
```

---

## 8️⃣ UI - Login Page

### `lib/presentation/pages/auth/login_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

/// Página de inicio de sesión
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      // Dispatch evento de login
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Login exitoso, navegar al dashboard
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (state is AuthError) {
            // Mostrar error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(
                    Icons.headset_mic,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // Título
                  Text(
                    'Call Center',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Iniciar Sesión',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo de email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su correo';
                      }
                      if (!value.contains('@')) {
                        return 'Ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      }
                      if (value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón de login
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return ElevatedButton(
                        onPressed: isLoading ? null : _onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Link de recuperación de contraseña
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/password-reset');
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 9️⃣ Configuración en main.dart

### `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/constants/api_constants.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/pages/auth/login_page.dart';
// import otras páginas...

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configurar Dio
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Crear instancias de dependencias
    final secureStorage = const FlutterSecureStorage();
    final authDataSource = AuthRemoteDataSource(dio: dio);
    final authRepository = AuthRepository(
      remoteDataSource: authDataSource,
      secureStorage: secureStorage,
    );

    return MultiBlocProvider(
      providers: [
        // BLoC de autenticación
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository)
            ..add(const CheckAuthStatus()), // Verificar sesión al iniciar
        ),
        // Agregar otros BLoCs aquí...
      ],
      child: MaterialApp(
        title: 'Call Center',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              // Mostrar splash screen mientras verifica sesión
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is Authenticated) {
              // Usuario autenticado, mostrar dashboard según rol
              return const DashboardPage(); // TODO: Implementar
            } else {
              // No autenticado, mostrar login
              return const LoginPage();
            }
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          // '/dashboard': (context) => const DashboardPage(),
          // Agregar otras rutas...
        },
      ),
    );
  }
}
```

---

## 🧪 Testing

### `test/data/repositories/auth_repository_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

// Imports del proyecto
import 'package:callcenter_mobile/data/repositories/auth_repository.dart';
import 'package:callcenter_mobile/data/datasources/auth_remote_datasource.dart';
import 'package:callcenter_mobile/data/models/auth/login_response_model.dart';

// Generar mocks con build_runner:
// flutter pub run build_runner build
@GenerateMocks([AuthRemoteDataSource, FlutterSecureStorage])
void main() {
  late AuthRepository repository;
  late MockAuthRemoteDataSource mockDataSource;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockStorage = MockFlutterSecureStorage();
    repository = AuthRepository(
      remoteDataSource: mockDataSource,
      secureStorage: mockStorage,
    );
  });

  group('login', () {
    test('should return LoginResponseModel on success', () async {
      // Arrange
      final tLoginResponse = LoginResponseModel(
        user: UserModel(/* ... */),
        tokens: AuthTokensModel(/* ... */),
      );
      
      when(mockDataSource.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => tLoginResponse);

      when(mockStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => null);

      // Act
      final result = await repository.login(
        email: 'test@test.com',
        password: 'password123',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (response) => expect(response, tLoginResponse),
      );

      verify(mockStorage.write(
        key: ApiConstants.accessTokenKey,
        value: tLoginResponse.tokens.accessToken,
      ));
    });

    test('should return InvalidCredentialsFailure on 400 status', () async {
      // Arrange
      when(mockDataSource.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // Act
      final result = await repository.login(
        email: 'wrong@test.com',
        password: 'wrongpass',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidCredentialsFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });
}
```

---

## ✅ Checklist de Implementación

- [x] Crear constantes de API
- [x] Crear modelos de datos con `fromJson` y `toJson`
- [x] Implementar data source remoto
- [x] Implementar repositorio con manejo de errores
- [x] Crear eventos del BLoC
- [x] Crear estados del BLoC
- [x] Implementar BLoC con handlers
- [x] Crear página de login con formulario
- [x] Configurar `main.dart` con providers
- [x] Escribir tests unitarios
- [ ] Agregar interceptor para JWT automático
- [ ] Implementar refresh automático de tokens
- [ ] Agregar animaciones y transiciones
- [ ] Mejorar manejo de errores con snackbars
- [ ] Agregar validaciones avanzadas

---

**Siguiente Paso:** Implementar módulos de Usuarios, Campañas y KPIs siguiendo este mismo patrón.
