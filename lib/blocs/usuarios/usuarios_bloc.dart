import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/usuario_model.dart';
import '../../services/user_service.dart';
import '../../utils/app_logger.dart';
import 'usuarios_event.dart';
import 'usuarios_state.dart';

/// BLoC para gestionar el estado de los usuarios
/// 
/// Maneja la carga, actualización, filtrado y gestión de usuarios del call center.
class UsuariosBloc extends Bloc<UsuariosEvent, UsuariosState> {
  UsuariosBloc() : super(const UsuariosInitial()) {
    on<LoadUsuarios>(_onLoadUsuarios);
    on<LoadUsuarioById>(_onLoadUsuarioById);
    on<LoadPerfilActual>(_onLoadPerfilActual);
    on<UpdateUsuario>(_onUpdateUsuario);
    on<ChangePassword>(_onChangePassword);
    on<FilterUsuariosByRole>(_onFilterUsuariosByRole);
    on<SearchUsuarios>(_onSearchUsuarios);
    on<LoadMoreUsuarios>(_onLoadMoreUsuarios);
    on<RefreshUsuarios>(_onRefreshUsuarios);
  }

  /// Maneja el evento de cargar usuarios con filtros
  Future<void> _onLoadUsuarios(
    LoadUsuarios event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      emit(const UsuariosLoading());

      final resultado = await UserService.listarUsuarios(
        role: event.role,
        isActive: event.isActive,
        search: event.search,
        page: event.page,
      );

      final usuarios = (resultado['results'] as List).cast<UsuarioModel>();
      final count = resultado['count'] as int;
      final hasMore = resultado['next'] != null;

      emit(UsuariosLoaded(
        usuarios: usuarios,
        totalCount: count,
        hasMore: hasMore,
        currentPage: event.page,
        filtroRole: event.role,
        filtroSearch: event.search,
      ));

      AppLogger.info('✅ Usuarios cargados: ${usuarios.length} de $count');
    } catch (e) {
      AppLogger.error('❌ Error al cargar usuarios: $e');
      emit(UsuariosError(e.toString()));
    }
  }

  /// Maneja el evento de cargar un usuario específico
  Future<void> _onLoadUsuarioById(
    LoadUsuarioById event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      emit(const UsuariosLoading());

      final usuario = await UserService.obtenerUsuario(event.documentoId);

      emit(UsuarioDetailLoaded(usuario));

      AppLogger.info('✅ Usuario ${event.documentoId} cargado exitosamente');
    } catch (e) {
      AppLogger.error('❌ Error al cargar usuario ${event.documentoId}: $e');
      emit(UsuariosError(e.toString()));
    }
  }

  /// Maneja el evento de cargar el perfil actual
  Future<void> _onLoadPerfilActual(
    LoadPerfilActual event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      emit(const UsuariosLoading());

      final perfil = await UserService.obtenerPerfilActual();

      emit(PerfilActualLoaded(perfil));

      AppLogger.info('✅ Perfil actual cargado: ${perfil.fullName}');
    } catch (e) {
      AppLogger.error('❌ Error al cargar perfil actual: $e');
      emit(UsuariosError(e.toString()));
    }
  }

  /// Maneja el evento de actualizar usuario
  Future<void> _onUpdateUsuario(
    UpdateUsuario event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      emit(const UsuariosLoading());

      final usuarioActualizado = await UserService.actualizarUsuario(
        documentoId: event.documentoId,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        fotoPerfil: event.fotoPerfil,
      );

      emit(UsuarioUpdated(
        usuarioActualizado,
        'Usuario actualizado exitosamente',
      ));

      AppLogger.info('✅ Usuario ${event.documentoId} actualizado');
    } catch (e) {
      AppLogger.error('❌ Error al actualizar usuario: $e');
      emit(UsuariosError(e.toString()));
    }
  }

  /// Maneja el evento de cambiar contraseña
  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      // Validar el request antes de enviar
      if (!event.request.isValid) {
        emit(UsuariosError(event.request.validationError!));
        return;
      }

      emit(const UsuariosLoading());

      final mensaje = await UserService.cambiarContrasena(event.request);

      emit(PasswordChanged(mensaje));

      AppLogger.info('✅ Contraseña cambiada exitosamente');
    } catch (e) {
      AppLogger.error('❌ Error al cambiar contraseña: $e');
      emit(UsuariosError(e.toString()));
    }
  }

  /// Maneja el evento de filtrar usuarios por rol
  Future<void> _onFilterUsuariosByRole(
    FilterUsuariosByRole event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      emit(const UsuariosLoading());

      final resultado = await UserService.listarUsuarios(
        role: event.role,
      );

      final usuarios = (resultado['results'] as List).cast<UsuarioModel>();
      final count = resultado['count'] as int;
      final hasMore = resultado['next'] != null;

      emit(UsuariosLoaded(
        usuarios: usuarios,
        totalCount: count,
        hasMore: hasMore,
        filtroRole: event.role,
      ));

      AppLogger.info('✅ Usuarios filtrados por rol "${event.role}": ${usuarios.length}');
    } catch (e) {
      AppLogger.error('❌ Error al filtrar usuarios: $e');
      emit(UsuariosError(e.toString()));
    }
  }

  /// Maneja el evento de buscar usuarios
  Future<void> _onSearchUsuarios(
    SearchUsuarios event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      if (event.searchTerm.isEmpty) {
        add(const LoadUsuarios());
        return;
      }

      emit(const UsuariosLoading());

      final resultado = await UserService.listarUsuarios(
        search: event.searchTerm,
      );

      final usuarios = (resultado['results'] as List).cast<UsuarioModel>();
      final count = resultado['count'] as int;

      emit(UsuariosLoaded(
        usuarios: usuarios,
        totalCount: count,
        hasMore: false,
        filtroSearch: event.searchTerm,
      ));

      AppLogger.info('✅ Búsqueda completada: ${usuarios.length} resultados');
    } catch (e) {
      AppLogger.error('❌ Error en búsqueda: $e');
      emit(UsuariosError(e.toString()));
    }
  }

  /// Maneja el evento de cargar más usuarios (paginación)
  Future<void> _onLoadMoreUsuarios(
    LoadMoreUsuarios event,
    Emitter<UsuariosState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UsuariosLoaded) return;
    if (!currentState.hasMore) return;

    try {
      emit(UsuariosLoadingMore(currentState.usuarios));

      final nextPage = currentState.currentPage + 1;
      final resultado = await UserService.listarUsuarios(
        role: currentState.filtroRole,
        search: currentState.filtroSearch,
        page: nextPage,
      );

      final newUsuarios = (resultado['results'] as List).cast<UsuarioModel>();
      final allUsuarios = [...currentState.usuarios, ...newUsuarios];
      final hasMore = resultado['next'] != null;

      emit(currentState.copyWith(
        usuarios: allUsuarios,
        hasMore: hasMore,
        currentPage: nextPage,
      ));

      AppLogger.info('✅ Más usuarios cargados: ${newUsuarios.length} (total: ${allUsuarios.length})');
    } catch (e) {
      AppLogger.error('❌ Error al cargar más usuarios: $e');
      emit(UsuariosError(
        e.toString(),
        previousUsuarios: currentState.usuarios,
      ));
    }
  }

  /// Maneja el evento de refrescar la lista
  Future<void> _onRefreshUsuarios(
    RefreshUsuarios event,
    Emitter<UsuariosState> emit,
  ) async {
    final currentState = state;

    String? filtroRole;
    String? filtroSearch;

    if (currentState is UsuariosLoaded) {
      filtroRole = currentState.filtroRole;
      filtroSearch = currentState.filtroSearch;
    }

    // Recargar desde la primera página
    add(LoadUsuarios(
      role: filtroRole,
      search: filtroSearch,
    ));
  }
}
