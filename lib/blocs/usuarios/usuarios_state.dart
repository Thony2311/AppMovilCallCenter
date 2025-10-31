import 'package:equatable/equatable.dart';
import '../../models/usuario_model.dart';

/// Estados para el BLoC de usuarios
abstract class UsuariosState extends Equatable {
  const UsuariosState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class UsuariosInitial extends UsuariosState {
  const UsuariosInitial();
}

/// Estado de carga
class UsuariosLoading extends UsuariosState {
  const UsuariosLoading();
}

/// Estado de éxito al cargar lista de usuarios
class UsuariosLoaded extends UsuariosState {
  final List<UsuarioModel> usuarios;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
  final String? filtroRole;
  final String? filtroSearch;

  const UsuariosLoaded({
    required this.usuarios,
    required this.totalCount,
    required this.hasMore,
    this.currentPage = 1,
    this.filtroRole,
    this.filtroSearch,
  });

  @override
  List<Object?> get props => [usuarios, totalCount, hasMore, currentPage, filtroRole, filtroSearch];

  UsuariosLoaded copyWith({
    List<UsuarioModel>? usuarios,
    int? totalCount,
    bool? hasMore,
    int? currentPage,
  }) {
    return UsuariosLoaded(
      usuarios: usuarios ?? this.usuarios,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filtroRole: filtroRole,
      filtroSearch: filtroSearch,
    );
  }
}

/// Estado de carga de más usuarios (paginación)
class UsuariosLoadingMore extends UsuariosState {
  final List<UsuarioModel> currentUsuarios;

  const UsuariosLoadingMore(this.currentUsuarios);

  @override
  List<Object?> get props => [currentUsuarios];
}

/// Estado de éxito al cargar un usuario individual
class UsuarioDetailLoaded extends UsuariosState {
  final UsuarioModel usuario;

  const UsuarioDetailLoaded(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

/// Estado de éxito al cargar el perfil actual
class PerfilActualLoaded extends UsuariosState {
  final UsuarioModel perfil;

  const PerfilActualLoaded(this.perfil);

  @override
  List<Object?> get props => [perfil];
}

/// Estado de éxito al actualizar usuario
class UsuarioUpdated extends UsuariosState {
  final UsuarioModel usuario;
  final String message;

  const UsuarioUpdated(this.usuario, this.message);

  @override
  List<Object?> get props => [usuario, message];
}

/// Estado de éxito al cambiar contraseña
class PasswordChanged extends UsuariosState {
  final String message;

  const PasswordChanged(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class UsuariosError extends UsuariosState {
  final String message;
  final List<UsuarioModel>? previousUsuarios;

  const UsuariosError(this.message, {this.previousUsuarios});

  @override
  List<Object?> get props => [message, previousUsuarios];
}
