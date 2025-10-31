import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/login_api.dart';
import '../models/usuario_model.dart';
import '../models/login_response_model.dart';
import '../config/auth_manager.dart';

// Eventos
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String email;  // Cambiado de username a email
  final String password;
  LoginSubmitted(this.email, this.password);
}

class LogoutRequested extends LoginEvent {}

// Estados
abstract class LoginState {}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final UsuarioModel user;
  LoginSuccess(this.user);
}
class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}
class LogoutSuccess extends LoginState {}

// BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginApi _api = LoginApi();
  final AuthManager _authManager = AuthManager();

  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      // Login retorna LoginResponseModel con user + tokens
      final LoginResponseModel response = await _api.login(event.email, event.password);
      
      // Guardar la sesión completa en AuthManager
      await _authManager.setSession(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
        user: response.user,
      );
      
      emit(LoginSuccess(response.user));
    } catch (e) {
      // Extraer mensaje de error
      String errorMsg = "Error de conexión";
      if (e.toString().contains('Exception:')) {
        errorMsg = e.toString().replaceAll('Exception:', '').trim();
      }
      emit(LoginFailure(errorMsg));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    try {
      // Obtener tokens antes de limpiar
      final refreshToken = await _authManager.getRefreshToken();
      final accessToken = _authManager.accessToken;
      
      // Intentar logout en el servidor
      if (refreshToken != null && accessToken != null) {
        await _api.logout(refreshToken, accessToken);
      }
      
      // Limpiar sesión local
      await _authManager.clearSession();
      
      emit(LogoutSuccess());
    } catch (e) {
      // Aunque falle, limpiar sesión local
      await _authManager.clearSession();
      emit(LogoutSuccess());
    }
  }
}
