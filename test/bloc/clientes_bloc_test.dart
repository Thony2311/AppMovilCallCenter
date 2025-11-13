import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:call_center_application/blocs/clientes/clientes_bloc.dart';
import 'package:call_center_application/blocs/clientes/clientes_event.dart';
import 'package:call_center_application/blocs/clientes/clientes_state.dart';
import 'package:call_center_application/models/clientes/cliente_model.dart';

// Mock del servicio
class MockClientesService extends Mock {
  static Future<Map<String, dynamic>> listarClientes({
    int? campana,
    String? search,
    int? baseDatos,
    int page = 1,
  }) async {
    // Simular una respuesta exitosa
    final mockClientes = [
      ClienteModel(
        clienteId: 1,
        campanaId: campana ?? 10,
        nombre: 'Cliente Test ${search ?? ''}',
        telefono: '3001234567',
        email: 'test@email.com',
      ),
      ClienteModel(
        clienteId: 2,
        campanaId: campana ?? 10,
        nombre: 'Otro Cliente ${search ?? ''}',
        telefono: '3007654321',
      ),
    ];

    return {
      'clientes': mockClientes,
      'count': mockClientes.length,
      'next': page < 2 ? 'next-page' : null,
    };
  }

  static Future<ClienteModel> obtenerCliente(int id) async {
    return ClienteModel(
      clienteId: id,
      campanaId: 10,
      nombre: 'Cliente Específico',
      telefono: '3001234567',
      email: 'cliente@email.com',
    );
  }

  static Future<List<ClienteModel>> buscarClientes(
    String termino, {
    int? campanaId,
  }) async {
    return [
      ClienteModel(
        clienteId: 1,
        campanaId: campanaId ?? 10,
        nombre: 'Cliente $termino',
        telefono: '3001234567',
      )
    ];
  }
}

void main() {
  late ClientesBloc clientesBloc;

  // Datos de prueba
  final mockCliente = ClienteModel(
    clienteId: 1,
    campanaId: 10,
    nombre: 'Juan Pérez',
    telefono: '3001234567',
    email: 'juan@email.com',
  );

  setUp(() {
    clientesBloc = ClientesBloc();
  });

  tearDown(() {
    clientesBloc.close();
  });

  group('ClientesBloc - Estados iniciales', () {
    test('estado inicial es ClientesInitial', () {
      expect(clientesBloc.state, const ClientesInitial());
    });
  });

  group('LoadClientes - Manejo de errores de autenticación', () {
    blocTest<ClientesBloc, ClientesState>(
      'emite [ClientesLoading, ClientesError] cuando no hay token',
      build: () => clientesBloc,
      act: (bloc) => bloc.add(const LoadClientes()),
      expect: () => [
        const ClientesLoading(),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );

    blocTest<ClientesBloc, ClientesState>(
      'emite [ClientesLoading, ClientesError] con filtros de campaña',
      build: () => clientesBloc,
      act: (bloc) => bloc.add(const LoadClientes(campana: 5)),
      expect: () => [
        const ClientesLoading(),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );

    blocTest<ClientesBloc, ClientesState>(
      'emite [ClientesLoading, ClientesError] con búsqueda',
      build: () => clientesBloc,
      act: (bloc) => bloc.add(const LoadClientes(search: 'test')),
      expect: () => [
        const ClientesLoading(),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );

    blocTest<ClientesBloc, ClientesState>(
      'emite [ClientesLoading, ClientesError] con página específica',
      build: () => clientesBloc,
      act: (bloc) => bloc.add(const LoadClientes(page: 2)),
      expect: () => [
        const ClientesLoading(),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );
  });

  group('LoadClienteById - Manejo de errores de autenticación', () {
    blocTest<ClientesBloc, ClientesState>(
      'emite [ClientesLoading, ClientesError] cuando no hay token',
      build: () => clientesBloc,
      act: (bloc) => bloc.add(const LoadClienteById(1)),
      expect: () => [
        const ClientesLoading(),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );
  });

  group('SearchClientes - Manejo de errores de autenticación', () {
    blocTest<ClientesBloc, ClientesState>(
      'emite [ClientesLoading, ClientesError] cuando no hay token',
      build: () => clientesBloc,
      act: (bloc) => bloc.add(const SearchClientes('test')),
      expect: () => [
        const ClientesLoading(),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );

    blocTest<ClientesBloc, ClientesState>(
      'emite [ClientesLoading, ClientesError] con filtro de campaña',
      build: () => clientesBloc,
      act: (bloc) => bloc.add(const SearchClientes('test', campanaId: 5)),
      expect: () => [
        const ClientesLoading(),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );
  });

  group('LoadMoreClientes - Comportamientos específicos', () {
    blocTest<ClientesBloc, ClientesState>(
      'no hace nada cuando el estado actual no es ClientesLoaded',
      build: () => clientesBloc,
      seed: () => const ClientesInitial(),
      act: (bloc) => bloc.add(const LoadMoreClientes()),
      expect: () => [],
    );

    blocTest<ClientesBloc, ClientesState>(
      'no hace nada cuando no hay más clientes para cargar',
      build: () => clientesBloc,
      seed: () => const ClientesLoaded(
        clientes: [],
        totalCount: 0,
        hasMore: false,
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const LoadMoreClientes()),
      expect: () => [],
    );

    blocTest<ClientesBloc, ClientesState>(
      'emite [ClientesLoadingMore, ClientesError] cuando no hay token',
      build: () => clientesBloc,
      seed: () => ClientesLoaded(
        clientes: [mockCliente],
        totalCount: 3,
        hasMore: true,
        currentPage: 1,
        filtroCampana: 1,
        filtroSearch: 'test',
      ),
      act: (bloc) => bloc.add(const LoadMoreClientes()),
      expect: () => [
        isA<ClientesLoadingMore>()
            .having((s) => s.currentClientes.length, 'currentClientes length', 1),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );
  });

  group('RefreshClientes - Comportamientos', () {
    blocTest<ClientesBloc, ClientesState>(
      'dispara LoadClientes y emite [ClientesLoading, ClientesError] cuando hay estado cargado',
      build: () => clientesBloc,
      seed: () => ClientesLoaded(
        clientes: [mockCliente],
        totalCount: 1,
        hasMore: false,
        currentPage: 1,
        filtroCampana: 5,
        filtroSearch: 'test',
      ),
      act: (bloc) => bloc.add(const RefreshClientes()),
      expect: () => [
        const ClientesLoading(),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );

    blocTest<ClientesBloc, ClientesState>(
      'dispara LoadClientes y emite [ClientesLoading, ClientesError] cuando no hay estado cargado',
      build: () => clientesBloc,
      seed: () => const ClientesInitial(),
      act: (bloc) => bloc.add(const RefreshClientes()),
      expect: () => [
        const ClientesLoading(),
        isA<ClientesError>()
            .having((e) => e.message, 'message', contains('token')),
      ],
    );
  });

  group('Validaciones de estructura del BLoC', () {
    test('bloc se cierra sin errores', () {
      expect(() => clientesBloc.close(), returnsNormally);
    });

    test('estado inicial es correcto', () {
      expect(clientesBloc.state, isA<ClientesInitial>());
    });
  });

  group('Validación de propiedades de eventos', () {
    test('LoadClientes tiene props correctos', () {
      const event = LoadClientes(campana: 1, search: 'test', page: 2);
      expect(event.props, [1, 'test', null, 2]);
    });

    test('LoadClienteById tiene props correctos', () {
      const event = LoadClienteById(1);
      expect(event.props, [1]);
    });

    test('SearchClientes tiene props correctos', () {
      const event = SearchClientes('test', campanaId: 1);
      expect(event.props, ['test', 1]);
    });

    test('LoadMoreClientes tiene props correctos', () {
      const event = LoadMoreClientes();
      expect(event.props, isEmpty);
    });

    test('RefreshClientes tiene props correctos', () {
      const event = RefreshClientes();
      expect(event.props, isEmpty);
    });
  });

}