import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/login_api.dart';
import '../../models/usuario_model.dart';

// Eventos
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String username;
  final String password;
  LoginSubmitted(this.username, this.password);
}

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

// BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginApi _api = LoginApi();

  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await _api.login(event.username, event.password);
      if (user == null) {
        emit(LoginFailure("Usuario o contraseña incorrectos"));
      } else {
        emit(LoginSuccess(user));
      }
    } catch (e) {
      emit(LoginFailure("Error de conexión"));
    }
  }
}
