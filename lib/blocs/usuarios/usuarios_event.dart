import 'package:equatable/equatable.dart';
import '../../models/change_password_request_model.dart';

/// Eventos para el BLoC de usuarios
abstract class UsuariosEvent extends Equatable {
  const UsuariosEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la lista de usuarios con filtros
class LoadUsuarios extends UsuariosEvent {
  final String? role;
  final bool? isActive;
  final String? search;
  final int page;

  const LoadUsuarios({
    this.role,
    this.isActive,
    this.search,
    this.page = 1,
  });

  @override
  List<Object?> get props => [role, isActive, search, page];
}

/// Evento para cargar un usuario específico por documento
class LoadUsuarioById extends UsuariosEvent {
  final String documentoId;

  const LoadUsuarioById(this.documentoId);

  @override
  List<Object?> get props => [documentoId];
}

/// Evento para cargar el perfil del usuario autenticado
class LoadPerfilActual extends UsuariosEvent {
  const LoadPerfilActual();
}

/// Evento para actualizar información del usuario
class UpdateUsuario extends UsuariosEvent {
  final String documentoId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? fotoPerfil;

  const UpdateUsuario({
    required this.documentoId,
    this.firstName,
    this.lastName,
    this.phone,
    this.fotoPerfil,
  });

  @override
  List<Object?> get props => [documentoId, firstName, lastName, phone, fotoPerfil];
}

/// Evento para cambiar contraseña
class ChangePassword extends UsuariosEvent {
  final ChangePasswordRequestModel request;

  const ChangePassword(this.request);

  @override
  List<Object?> get props => [request];
}

/// Evento para filtrar usuarios por rol
class FilterUsuariosByRole extends UsuariosEvent {
  final String role;

  const FilterUsuariosByRole(this.role);

  @override
  List<Object?> get props => [role];
}

/// Evento para buscar usuarios
class SearchUsuarios extends UsuariosEvent {
  final String searchTerm;

  const SearchUsuarios(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

/// Evento para cargar más usuarios (paginación)
class LoadMoreUsuarios extends UsuariosEvent {
  const LoadMoreUsuarios();
}

/// Evento para refrescar la lista
class RefreshUsuarios extends UsuariosEvent {
  const RefreshUsuarios();
}
