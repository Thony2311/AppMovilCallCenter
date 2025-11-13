import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:call_center_application/blocs/equipos/equipos_bloc.dart';
import 'package:call_center_application/blocs/equipos/equipos_event.dart';
import 'package:call_center_application/blocs/equipos/equipos_state.dart';
import 'package:call_center_application/models/equipos/equipo_model.dart';
import 'package:call_center_application/services/equipos_service.dart';

// Mock del servicio
class MockEquiposService extends Mock implements EquiposServiceInterface {}

void main() {
  late EquiposBloc equiposBloc;
  late MockEquiposService mockService;

  // Datos de prueba
  final mockEquipo = EquipoModel(
    equipoId: 1,
    nombre: 'Equipo Alpha',
    agentes: [],
    cantidadAgentes: 3,
    isActive: true,
  );

  final mockEquipo2 = EquipoModel(
    equipoId: 2,
    nombre: 'Equipo Beta',
    agentes: [],
    cantidadAgentes: 2,
    isActive: true,
  );

  setUp(() {
    mockService = MockEquiposService();
    equiposBloc = EquiposBloc(service: mockService);
  });

  tearDown(() {
    equiposBloc.close();
  });

  group('EquiposBloc - Estados iniciales', () {
    test('estado inicial es EquiposInitial', () {
      expect(equiposBloc.state, const EquiposInitial());
    });
  });

  group('LoadEquipos - Escenarios exitosos', () {
    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposLoaded] cuando LoadEquipos es exitoso',
      setUp: () {
        when(() => mockService.listarEquiposInstance()).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo],
            'count': 1,
            'next': null,
            'previous': null,
          },
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipos()),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>()
            .having((s) => s.equipos.length, 'equipos length', 1)
            .having((s) => s.totalCount, 'totalCount', 1)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposLoaded] con filtros de campaña',
      setUp: () {
        when(() => mockService.listarEquiposInstance(campana: 5)).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo],
            'count': 1,
            'next': null,
            'previous': null,
          },
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipos(campana: 5)),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>()
            .having((s) => s.equipos.length, 'equipos length', 1),
      ],
    );

    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposLoaded] con filtro de coordinador',
      setUp: () {
        when(() => mockService.listarEquiposInstance(coordinador: 'coord123')).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo],
            'count': 1,
            'next': null,
            'previous': null,
          },
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipos(coordinador: 'coord123')),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>()
            .having((s) => s.equipos.length, 'equipos length', 1),
      ],
    );

    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposLoaded] con filtro de estado activo',
      setUp: () {
        when(() => mockService.listarEquiposInstance(isActive: true)).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo],
            'count': 1,
            'next': null,
            'previous': null,
          },
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipos(isActive: true)),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>()
            .having((s) => s.equipos.length, 'equipos length', 1),
      ],
    );

    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposLoaded] con paginación',
      setUp: () {
        when(() => mockService.listarEquiposInstance(page: 2)).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo2],
            'count': 2,
            'next': 'next-page',
            'previous': 'previous-page',
          },
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipos(page: 2)),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>()
            .having((s) => s.equipos.length, 'equipos length', 1)
            .having((s) => s.totalCount, 'totalCount', 2)
            .having((s) => s.hasMore, 'hasMore', true),
      ],
    );
  });

  group('LoadEquipos - Escenarios de error', () {
    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposError] cuando el servicio falla',
      setUp: () {
        when(() => mockService.listarEquiposInstance()).thenThrow(
          Exception('Error de conexión'),
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipos()),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposError>()
            .having((e) => e.message, 'message', 'Exception: Error de conexión'),
      ],
    );

    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposError] con filtros cuando el servicio falla',
      setUp: () {
        when(() => mockService.listarEquiposInstance(campana: 5)).thenThrow(
          Exception('Error de autenticación'),
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipos(campana: 5)),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposError>()
            .having((e) => e.message, 'message', 'Exception: Error de autenticación'),
      ],
    );
  });

  group('LoadEquipoById - Escenarios exitosos', () {
    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquipoDetailLoaded] cuando LoadEquipoById es exitoso',
      setUp: () {
        when(() => mockService.obtenerEquipoInstance(1)).thenAnswer(
          (_) async => mockEquipo,
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipoById(1)),
      expect: () => [
        const EquiposLoading(),
        isA<EquipoDetailLoaded>()
            .having((s) => s.equipo.equipoId, 'equipoId', 1)
            .having((s) => s.equipo.nombre, 'nombre', 'Equipo Alpha'),
      ],
    );
  });

  group('LoadEquipoById - Escenarios de error', () {
    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposError] cuando LoadEquipoById falla',
      setUp: () {
        when(() => mockService.obtenerEquipoInstance(1)).thenThrow(
          Exception('Equipo no encontrado'),
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipoById(1)),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposError>()
            .having((e) => e.message, 'message', 'Exception: Equipo no encontrado'),
      ],
    );
  });

  group('LoadEquiposActivos - Escenarios exitosos', () {
    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposLoaded] cuando LoadEquiposActivos es exitoso',
      setUp: () {
        when(() => mockService.listarEquiposActivosInstance()).thenAnswer(
          (_) async => [mockEquipo, mockEquipo2],
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquiposActivos()),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>()
            .having((s) => s.equipos.length, 'equipos length', 2)
            .having((s) => s.totalCount, 'totalCount', 2)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );
  });

  group('LoadEquiposActivos - Escenarios de error', () {
    blocTest<EquiposBloc, EquiposState>(
      'emite [EquiposLoading, EquiposError] cuando LoadEquiposActivos falla',
      setUp: () {
        when(() => mockService.listarEquiposActivosInstance()).thenThrow(
          Exception('Error al cargar equipos activos'),
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquiposActivos()),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposError>()
            .having((e) => e.message, 'message', 'Exception: Error al cargar equipos activos'),
      ],
    );
  });

  group('RefreshEquipos - Comportamientos', () {
    blocTest<EquiposBloc, EquiposState>(
      'dispara LoadEquipos cuando se llama RefreshEquipos',
      setUp: () {
        when(() => mockService.listarEquiposInstance()).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo],
            'count': 1,
            'next': null,
            'previous': null,
          },
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const RefreshEquipos()),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>()
            .having((s) => s.equipos.length, 'equipos length', 1),
      ],
    );

    blocTest<EquiposBloc, EquiposState>(
      'dispara LoadEquipos desde cualquier estado',
      setUp: () {
        when(() => mockService.listarEquiposInstance()).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo],
            'count': 1,
            'next': null,
            'previous': null,
          },
        );
      },
      build: () => equiposBloc,
      seed: () => EquiposLoaded(
        equipos: [mockEquipo],
        totalCount: 1,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const RefreshEquipos()),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>(),
      ],
    );
  });

  group('Validaciones de estructura del BLoC', () {
    test('bloc se cierra sin errores', () {
      expect(() => equiposBloc.close(), returnsNormally);
    });

    test('estado inicial es correcto', () {
      expect(equiposBloc.state, isA<EquiposInitial>());
    });
  });

  group('Validación de propiedades de eventos', () {
    test('LoadEquipos tiene props correctos sin filtros', () {
      const event = LoadEquipos();
      expect(event.props, [null, null, null, 1]);
    });

    test('LoadEquipos tiene props correctos con todos los filtros', () {
      const event = LoadEquipos(
        campana: 5,
        coordinador: 'coord123',
        isActive: true,
        page: 2,
      );
      expect(event.props, [5, 'coord123', true, 2]);
    });

    test('LoadEquipoById tiene props correctos', () {
      const event = LoadEquipoById(1);
      expect(event.props, [1]);
    });

    test('LoadEquiposActivos tiene props correctos', () {
      const event = LoadEquiposActivos();
      expect(event.props, isEmpty);
    });

    test('RefreshEquipos tiene props correctos', () {
      const event = RefreshEquipos();
      expect(event.props, isEmpty);
    });
  });

  group('Validación de igualdad de eventos', () {
    test('LoadEquipos con mismos filtros son iguales', () {
      const event1 = LoadEquipos(campana: 1, coordinador: 'test');
      const event2 = LoadEquipos(campana: 1, coordinador: 'test');
      expect(event1, event2);
    });

    test('LoadEquipos con diferentes filtros son diferentes', () {
      const event1 = LoadEquipos(campana: 1);
      const event2 = LoadEquipos(campana: 2);
      expect(event1, isNot(event2));
    });

    test('LoadEquipoById con mismo ID son iguales', () {
      const event1 = LoadEquipoById(1);
      const event2 = LoadEquipoById(1);
      expect(event1, event2);
    });

    test('LoadEquipoById con diferente ID son diferentes', () {
      const event1 = LoadEquipoById(1);
      const event2 = LoadEquipoById(2);
      expect(event1, isNot(event2));
    });

    test('LoadEquiposActivos siempre son iguales', () {
      const event1 = LoadEquiposActivos();
      const event2 = LoadEquiposActivos();
      expect(event1, event2);
    });

    test('RefreshEquipos siempre son iguales', () {
      const event1 = RefreshEquipos();
      const event2 = RefreshEquipos();
      expect(event1, event2);
    });
  });

  group('Validación de estados', () {
    test('EquiposInitial tiene props vacíos', () {
      const state = EquiposInitial();
      expect(state.props, isEmpty);
    });

    test('EquiposLoading tiene props vacíos', () {
      const state = EquiposLoading();
      expect(state.props, isEmpty);
    });

    test('EquiposLoaded tiene props correctos', () {
      final state = EquiposLoaded(
        equipos: [mockEquipo],
        totalCount: 1,
        hasMore: false,
      );
      expect(state.props, [
        [mockEquipo],
        1,
        false,
      ]);
    });

    test('EquipoDetailLoaded tiene props correctos', () {
      final state = EquipoDetailLoaded(mockEquipo);
      expect(state.props, [mockEquipo]);
    });

    test('EquiposError tiene props correctos', () {
      const state = EquiposError('Error message');
      expect(state.props, ['Error message']);
    });
  });

  group('Flujo completo de eventos', () {
    blocTest<EquiposBloc, EquiposState>(
      'procesa secuencia completa de eventos exitosos',
      setUp: () {
        when(() => mockService.listarEquiposInstance()).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo],
            'count': 1,
            'next': null,
            'previous': null,
          },
        );
        when(() => mockService.obtenerEquipoInstance(1)).thenAnswer(
          (_) async => mockEquipo,
        );
        when(() => mockService.listarEquiposActivosInstance()).thenAnswer(
          (_) async => [mockEquipo, mockEquipo2],
        );
      },
      build: () => equiposBloc,
      act: (bloc) {
        // Flujo típico de uso
        bloc.add(const LoadEquipos());
        bloc.add(const LoadEquipoById(1));
        bloc.add(const LoadEquiposActivos());
        bloc.add(const RefreshEquipos());
      },
      expect: () => [
        // LoadEquipos
        const EquiposLoading(),
        isA<EquiposLoaded>(),
        // LoadEquipoById
        const EquiposLoading(),
        isA<EquipoDetailLoaded>(),
        // LoadEquiposActivos
        const EquiposLoading(),
        isA<EquiposLoaded>(),
        // RefreshEquipos
        const EquiposLoading(),
        isA<EquiposLoaded>(),
      ],
    );
  });

  group('Comportamiento de paginación', () {
    blocTest<EquiposBloc, EquiposState>(
      'hasMore es true cuando hay siguiente página',
      setUp: () {
        when(() => mockService.listarEquiposInstance()).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo],
            'count': 3,
            'next': 'next-page',
            'previous': null,
          },
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipos()),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>()
            .having((s) => s.hasMore, 'hasMore', true)
            .having((s) => s.totalCount, 'totalCount', 3),
      ],
    );

    blocTest<EquiposBloc, EquiposState>(
      'hasMore es false cuando no hay siguiente página',
      setUp: () {
        when(() => mockService.listarEquiposInstance()).thenAnswer(
          (_) async => {
            'equipos': [mockEquipo],
            'count': 1,
            'next': null,
            'previous': null,
          },
        );
      },
      build: () => equiposBloc,
      act: (bloc) => bloc.add(const LoadEquipos()),
      expect: () => [
        const EquiposLoading(),
        isA<EquiposLoaded>()
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.totalCount, 'totalCount', 1),
      ],
    );
  });
}