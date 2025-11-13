// test/unit/bloc/usuarios_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:call_center_application/blocs/usuarios/usuarios_event.dart';
import 'package:call_center_application/blocs/usuarios/usuarios_state.dart';
import 'package:call_center_application/blocs/usuarios/usuarios_bloc.dart';
import 'package:call_center_application/services/user_service.dart';
import 'package:call_center_application/models/usuario_model.dart';
import 'package:call_center_application/models/change_password_request_model.dart';

// Mocks para los modelos
class MockUsuarioModel extends Mock implements UsuarioModel {
  @override
  String get documentoId => 'test_user_123';
  
  @override
  String get fullName => 'Test User';
  
  @override
  String get email => 'test@example.com';
  
  @override
  String get role => 'AGENTE';
  
  @override
  bool get isActive => true;
}

// Mock mejorado para ChangePasswordRequestModel
class MockChangePasswordRequestModel extends Mock implements ChangePasswordRequestModel {
  final bool _isValid;
  final String? _validationError;

  MockChangePasswordRequestModel({bool isValid = true, String? validationError})
      : _isValid = isValid,
        _validationError = validationError;

  @override
  bool get isValid => _isValid;
  
  @override
  String? get validationError => _validationError;
  
  @override
  String get oldPassword => 'oldPassword123';
  
  @override
  String get newPassword => 'newPassword123';
  
  @override
  String get newPasswordConfirm => 'newPassword123';
}

class MockUserService extends Mock implements UserServiceInterface {}

void main() {
  late MockUserService mockUserService;
  late UsuariosBloc usuariosBloc;

  setUp(() {
    mockUserService = MockUserService();
    usuariosBloc = UsuariosBloc(service: mockUserService);
    
    // Configurar fallback values para manejar parámetros nulos
    registerFallbackValue(const LoadUsuarios());
    registerFallbackValue(const LoadPerfilActual());
    registerFallbackValue(const LoadMoreUsuarios());
    registerFallbackValue(const RefreshUsuarios());
    registerFallbackValue(MockChangePasswordRequestModel());
  });

  tearDown(() {
    usuariosBloc.close();
  });

  // Helper para crear respuesta de lista de usuarios
  Map<String, dynamic> createUsersResponse({int count = 2, bool hasNext = false}) {
    return {
      'count': count,
      'next': hasNext ? 'http://next-page.com' : null,
      'previous': null,
      'results': List.generate(count, (index) => MockUsuarioModel()),
    };
  }

  group('UsuariosBloc - Pruebas Unitarias', () {
    // ========== PRUEBAS PARA LoadUsuarios ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoading, UsuariosLoaded] cuando LoadUsuarios es exitoso',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(
          role: any(named: 'role'),
          isActive: any(named: 'isActive'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => createUsersResponse());
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const LoadUsuarios()),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>()
          .having((state) => state.usuarios.length, 'usuarios.length', 2)
          .having((state) => state.totalCount, 'totalCount', 2)
          .having((state) => state.hasMore, 'hasMore', false),
      ],
      verify: (_) {
        verify(() => mockUserService.listarUsuariosInstance(
          role: null,
          isActive: null,
          search: null,
          page: 1,
        )).called(1);
      },
    );

    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoading, UsuariosError] cuando LoadUsuarios falla',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(
          role: any(named: 'role'),
          isActive: any(named: 'isActive'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        )).thenThrow(Exception('Error de red'));
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const LoadUsuarios()),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosError>(),
      ],
    );

    blocTest<UsuariosBloc, UsuariosState>(
      'debe pasar filtros correctos al servicio en LoadUsuarios',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(
          role: 'AGENTE',
          isActive: true,
          search: 'test',
          page: 2,
        )).thenAnswer((_) async => createUsersResponse());
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const LoadUsuarios(
        role: 'AGENTE',
        isActive: true,
        search: 'test',
        page: 2,
      )),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>(),
      ],
      verify: (_) {
        verify(() => mockUserService.listarUsuariosInstance(
          role: 'AGENTE',
          isActive: true,
          search: 'test',
          page: 2,
        )).called(1);
      },
    );

    // ========== PRUEBAS PARA LoadUsuarioById ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoading, UsuarioDetailLoaded] cuando LoadUsuarioById es exitoso',
      build: () {
        when(() => mockUserService.obtenerUsuarioInstance('test_user_123'))
            .thenAnswer((_) async => MockUsuarioModel());
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const LoadUsuarioById('test_user_123')),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuarioDetailLoaded>(),
      ],
      verify: (_) {
        verify(() => mockUserService.obtenerUsuarioInstance('test_user_123')).called(1);
      },
    );

    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoading, UsuariosError] cuando LoadUsuarioById falla',
      build: () {
        when(() => mockUserService.obtenerUsuarioInstance('test_user_123'))
            .thenThrow(Exception('Usuario no encontrado'));
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const LoadUsuarioById('test_user_123')),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosError>(),
      ],
    );

    // ========== PRUEBAS PARA LoadPerfilActual ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoading, PerfilActualLoaded] cuando LoadPerfilActual es exitoso',
      build: () {
        when(() => mockUserService.obtenerPerfilActualInstance())
            .thenAnswer((_) async => MockUsuarioModel());
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const LoadPerfilActual()),
      expect: () => [
        const UsuariosLoading(),
        isA<PerfilActualLoaded>(),
      ],
      verify: (_) {
        verify(() => mockUserService.obtenerPerfilActualInstance()).called(1);
      },
    );

    // ========== PRUEBAS PARA UpdateUsuario ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoading, UsuarioUpdated] cuando UpdateUsuario es exitoso',
      build: () {
        when(() => mockUserService.actualizarUsuarioInstance(
          documentoId: 'test_user_123',
          firstName: 'Nuevo',
          lastName: 'Nombre',
          phone: '123456789',
          fotoPerfil: 'foto.jpg',
        )).thenAnswer((_) async => MockUsuarioModel());
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const UpdateUsuario(
        documentoId: 'test_user_123',
        firstName: 'Nuevo',
        lastName: 'Nombre',
        phone: '123456789',
        fotoPerfil: 'foto.jpg',
      )),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuarioUpdated>(),
      ],
      verify: (_) {
        verify(() => mockUserService.actualizarUsuarioInstance(
          documentoId: 'test_user_123',
          firstName: 'Nuevo',
          lastName: 'Nombre',
          phone: '123456789',
          fotoPerfil: 'foto.jpg',
        )).called(1);
      },
    );

    // ========== PRUEBAS CORREGIDAS PARA ChangePassword ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoading, PasswordChanged] cuando ChangePassword es exitoso',
      build: () {
        // Configurar el mock del servicio
        when(() => mockUserService.cambiarContrasenaInstance(any()))
            .thenAnswer((_) async => 'Contraseña actualizada exitosamente');
        
        return usuariosBloc;
      },
      act: (bloc) {
        // Crear un request válido
        final request = MockChangePasswordRequestModel(isValid: true);
        bloc.add(ChangePassword(request));
      },
      expect: () => [
        const UsuariosLoading(),
        isA<PasswordChanged>(),
      ],
      verify: (_) {
        verify(() => mockUserService.cambiarContrasenaInstance(any())).called(1);
      },
    );

    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir UsuariosError cuando ChangePassword tiene request inválido',
      build: () => usuariosBloc,
      act: (bloc) {
        // Crear un request inválido
        final request = MockChangePasswordRequestModel(
          isValid: false, 
          validationError: 'Las contraseñas no coinciden'
        );
        bloc.add(ChangePassword(request));
      },
      expect: () => [
        isA<UsuariosError>()
          .having((error) => error.message, 'message', 'Las contraseñas no coinciden'),
      ],
      verify: (_) {
        verifyNever(() => mockUserService.cambiarContrasenaInstance(any()));
      },
    );

    // ========== PRUEBAS PARA FilterUsuariosByRole ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoading, UsuariosLoaded] cuando FilterUsuariosByRole es exitoso',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(role: 'AGENTE'))
            .thenAnswer((_) async => createUsersResponse(count: 3));
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const FilterUsuariosByRole('AGENTE')),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>()
          .having((state) => state.usuarios.length, 'usuarios.length', 3)
          .having((state) => state.filtroRole, 'filtroRole', 'AGENTE'),
      ],
      verify: (_) {
        verify(() => mockUserService.listarUsuariosInstance(role: 'AGENTE')).called(1);
      },
    );

    // ========== PRUEBAS PARA SearchUsuarios ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoading, UsuariosLoaded] cuando SearchUsuarios es exitoso',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(search: 'test'))
            .thenAnswer((_) async => createUsersResponse(count: 1));
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const SearchUsuarios('test')),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>()
          .having((state) => state.usuarios.length, 'usuarios.length', 1)
          .having((state) => state.filtroSearch, 'filtroSearch', 'test'),
      ],
      verify: (_) {
        verify(() => mockUserService.listarUsuariosInstance(search: 'test')).called(1);
      },
    );

    blocTest<UsuariosBloc, UsuariosState>(
      'debe cargar todos los usuarios cuando SearchUsuarios tiene término vacío',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(
          role: any(named: 'role'),
          isActive: any(named: 'isActive'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => createUsersResponse());
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const SearchUsuarios('')),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>(),
      ],
    );

    // ========== PRUEBAS PARA LoadMoreUsuarios ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe emitir [UsuariosLoadingMore, UsuariosLoaded] cuando LoadMoreUsuarios es exitoso',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(
          role: 'AGENTE',
          search: 'test',
          page: 2,
        )).thenAnswer((_) async => createUsersResponse(count: 2, hasNext: true));
        
        final bloc = UsuariosBloc(service: mockUserService);
        // Estado inicial con usuarios cargados y tiene más páginas
        bloc.emit(UsuariosLoaded(
          usuarios: [MockUsuarioModel(), MockUsuarioModel()],
          totalCount: 10,
          hasMore: true,
          currentPage: 1,
          filtroRole: 'AGENTE',
          filtroSearch: 'test',
        ));
        
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMoreUsuarios()),
      expect: () => [
        isA<UsuariosLoadingMore>(),
        isA<UsuariosLoaded>()
          .having((state) => state.usuarios.length, 'usuarios.length', 4)
          .having((state) => state.currentPage, 'currentPage', 2),
      ],
      verify: (_) {
        verify(() => mockUserService.listarUsuariosInstance(
          role: 'AGENTE',
          search: 'test',
          page: 2,
        )).called(1);
      },
    );

    blocTest<UsuariosBloc, UsuariosState>(
      'no debe hacer nada en LoadMoreUsuarios si no hay más páginas',
      build: () {
        final bloc = UsuariosBloc(service: mockUserService);
        // Estado inicial sin más páginas
        bloc.emit(UsuariosLoaded(
          usuarios: [MockUsuarioModel()],
          totalCount: 1,
          hasMore: false,
        ));
        
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMoreUsuarios()),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockUserService.listarUsuariosInstance());
      },
    );

    blocTest<UsuariosBloc, UsuariosState>(
      'debe mantener usuarios anteriores en LoadMoreUsuarios con error',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(
          role: any(named: 'role'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        )).thenThrow(Exception('Error de paginación'));
        
        final bloc = UsuariosBloc(service: mockUserService);
        final usuariosPrevios = [MockUsuarioModel(), MockUsuarioModel()];
        bloc.emit(UsuariosLoaded(
          usuarios: usuariosPrevios,
          totalCount: 10,
          hasMore: true,
          currentPage: 1,
        ));
        
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMoreUsuarios()),
      expect: () => [
        isA<UsuariosLoadingMore>(),
        isA<UsuariosError>()
          .having((error) => error.previousUsuarios, 'previousUsuarios', isNotNull),
      ],
    );

    // ========== PRUEBAS CORREGIDAS PARA RefreshUsuarios ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe enviar LoadUsuarios con filtros actuales en RefreshUsuarios',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(
          role: 'AGENTE',
          search: 'test',
          page: 1,
        )).thenAnswer((_) async => createUsersResponse());
        
        final bloc = UsuariosBloc(service: mockUserService);
        bloc.emit(UsuariosLoaded(
          usuarios: [MockUsuarioModel()],
          totalCount: 1,
          hasMore: false,
          filtroRole: 'AGENTE',
          filtroSearch: 'test',
        ));
        
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshUsuarios()),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>(),
      ],
    );

    // ========== PRUEBAS DE SERVICE FALLBACK ==========
    blocTest<UsuariosBloc, UsuariosState>(
      'debe usar servicio inyectado cuando está disponible',
      build: () {
        final testBloc = UsuariosBloc(service: mockUserService);
        
        when(() => mockUserService.listarUsuariosInstance(
          role: any(named: 'role'),
          isActive: any(named: 'isActive'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => createUsersResponse());
        
        return testBloc;
      },
      act: (bloc) => bloc.add(const LoadUsuarios()),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>(),
      ],
      verify: (_) {
        verify(() => mockUserService.listarUsuariosInstance(
          role: null,
          isActive: null,
          search: null,
          page: 1,
        )).called(1);
      },
    );

    test('debe funcionar sin servicio inyectado (usar métodos estáticos)', () {
      // Esta prueba verifica que el BLoC puede crearse sin servicio inyectado
      final blocSinService = UsuariosBloc();
      expect(blocSinService.state, const UsuariosInitial());
      blocSinService.close();
    });
  });

  group('UsuariosBloc - Edge Cases', () {
    blocTest<UsuariosBloc, UsuariosState>(
      'debe manejar lista vacía de usuarios',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(
          role: any(named: 'role'),
          isActive: any(named: 'isActive'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => {
          'count': 0,
          'next': null,
          'previous': null,
          'results': [],
        });
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const LoadUsuarios()),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>()
          .having((state) => state.usuarios, 'usuarios vacíos', isEmpty)
          .having((state) => state.totalCount, 'totalCount', 0),
      ],
    );

    blocTest<UsuariosBloc, UsuariosState>(
      'debe manejar múltiples eventos secuencialmente',
      build: () {
        // Configurar ambos mocks
        when(() => mockUserService.listarUsuariosInstance(
          role: any(named: 'role'),
          isActive: any(named: 'isActive'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => createUsersResponse());
        
        when(() => mockUserService.obtenerPerfilActualInstance())
            .thenAnswer((_) async => MockUsuarioModel());
        
        return usuariosBloc;
      },
      act: (bloc) {
        bloc.add(const LoadUsuarios());
        bloc.add(const LoadPerfilActual());
      },
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>(),
        const UsuariosLoading(),
        isA<PerfilActualLoaded>(),
      ],
    );

    blocTest<UsuariosBloc, UsuariosState>(
      'debe manejar RefreshUsuarios en estado inicial sin errores',
      build: () {
        when(() => mockUserService.listarUsuariosInstance(
          role: any(named: 'role'),
          isActive: any(named: 'isActive'),
          search: any(named: 'search'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => createUsersResponse());
        
        return usuariosBloc;
      },
      act: (bloc) => bloc.add(const RefreshUsuarios()),
      expect: () => [
        const UsuariosLoading(),
        isA<UsuariosLoaded>(),
      ],
    );
  });

  // ... (resto de las pruebas de State Properties se mantienen igual)
}