import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:call_center_application/blocs/campanas/campanas_bloc.dart';
import 'package:call_center_application/blocs/campanas/campanas_event.dart';
import 'package:call_center_application/blocs/campanas/campanas_state.dart';
import 'package:call_center_application/models/campanas/campana_model.dart';
import 'package:call_center_application/services/campanas_service.dart';

// Mocks
class MockCampanasService extends Mock implements CampanasServiceInterface {}

class MockCampanaModel extends Mock implements CampanaModel {}

void main() {
  late MockCampanasService mockService;
  late CampanasBloc campanasBloc;

  // Datos de prueba
  final campanaMock = CampanaModel(
    id: 1,
    nombre: 'Campaña Test',
    descripcion: 'Descripción de prueba',
    fechaInicio: DateTime(2024, 1, 1),
    fechaFin: DateTime(2024, 12, 31),
    estadoId: 1,
    estadoNombre: 'ACTIVA',
    objetivoLlamadas: 1000,
    objetivoVentas: 100,
    jefeCampanaId: 'user123',
    centroId: 1,
    centroNombre: 'Centro Principal',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final campanaListMock = [
    campanaMock,
    CampanaModel(
      id: 2,
      nombre: 'Campaña Test 2',
      fechaInicio: DateTime(2024, 2, 1),
      fechaFin: DateTime(2024, 11, 30),
      estadoId: 2,
      estadoNombre: 'PAUSADA',
      createdAt: DateTime(2024, 2, 1),
      updatedAt: DateTime(2024, 2, 1),
    ),
  ];

  final resultadoListaMock = {
    'campanas': campanaListMock,
    'count': 2,
    'next': null,
    'previous': null,
  };

  final resultadoListaConPaginacionMock = {
    'campanas': campanaListMock,
    'count': 10,
    'next': 'https://api.com/campanas?page=2',
    'previous': null,
  };

  setUp(() {
    mockService = MockCampanasService();
    campanasBloc = CampanasBloc(service: mockService);
  });

  tearDown(() {
    campanasBloc.close();
  });

  group('CampanasBloc - Pruebas básicas', () {
    test('estado inicial es CampanasInitial', () {
      expect(campanasBloc.state, equals(const CampanasInitial()));
    });

    test('cierra correctamente', () {
      expect(() => campanasBloc.close(), returnsNormally);
    });
  });

  group('LoadCampanas', () {
    blocTest<CampanasBloc, CampanasState>(
      'emite [CampanasLoading, CampanasLoaded] cuando LoadCampanas es exitoso',
      build: () {
        when(() => mockService.listarCampanasInstance(
          estado: any(named: 'estado'),
          jefeCampana: any(named: 'jefeCampana'),
          centro: any(named: 'centro'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => resultadoListaMock);
        return campanasBloc;
      },
      act: (bloc) => bloc.add(const LoadCampanas()),
      expect: () => [
        const CampanasLoading(),
        CampanasLoaded(
          campanas: campanaListMock,
          totalCount: 2,
          hasMore: false,
          currentPage: 1,
        ),
      ],
      verify: (_) {
        verify(() => mockService.listarCampanasInstance(
          estado: null,
          jefeCampana: null,
          centro: null,
          page: 1,
        )).called(1);
      },
    );

    blocTest<CampanasBloc, CampanasState>(
      'emite [CampanasLoading, CampanasError] cuando LoadCampanas falla',
      build: () {
        when(() => mockService.listarCampanasInstance(
          estado: any(named: 'estado'),
          jefeCampana: any(named: 'jefeCampana'),
          centro: any(named: 'centro'),
          page: any(named: 'page'),
        )).thenThrow(Exception('Error de red'));
        return campanasBloc;
      },
      act: (bloc) => bloc.add(const LoadCampanas()),
      expect: () => [
        const CampanasLoading(),
        const CampanasError('Exception: Error de red'),
      ],
    );

    blocTest<CampanasBloc, CampanasState>(
      'carga campañas con filtros correctamente',
      build: () {
        when(() => mockService.listarCampanasInstance(
          estado: 'ACTIVA',
          jefeCampana: 'user123',
          centro: 1,
          page: 1,
        )).thenAnswer((_) async => resultadoListaMock);
        return campanasBloc;
      },
      act: (bloc) => bloc.add(const LoadCampanas(
        estado: 'ACTIVA',
        jefeCampana: 'user123',
        centro: 1,
        page: 1,
      )),
      expect: () => [
        const CampanasLoading(),
        CampanasLoaded(
          campanas: campanaListMock,
          totalCount: 2,
          hasMore: false,
          currentPage: 1,
          filtroEstado: 'ACTIVA',
        ),
      ],
    );
  });

  group('LoadCampanaById', () {
    blocTest<CampanasBloc, CampanasState>(
      'emite [CampanasLoading, CampanaDetailLoaded] cuando LoadCampanaById es exitoso',
      build: () {
        when(() => mockService.obtenerCampanaInstance(1))
            .thenAnswer((_) async => campanaMock);
        return campanasBloc;
      },
      act: (bloc) => bloc.add(const LoadCampanaById(1)),
      expect: () => [
        const CampanasLoading(),
        CampanaDetailLoaded(campanaMock),
      ],
      verify: (_) {
        verify(() => mockService.obtenerCampanaInstance(1)).called(1);
      },
    );

    blocTest<CampanasBloc, CampanasState>(
      'emite [CampanasLoading, CampanasError] cuando LoadCampanaById falla',
      build: () {
        when(() => mockService.obtenerCampanaInstance(1))
            .thenThrow(Exception('Campaña no encontrada'));
        return campanasBloc;
      },
      act: (bloc) => bloc.add(const LoadCampanaById(1)),
      expect: () => [
        const CampanasLoading(),
        const CampanasError('Exception: Campaña no encontrada'),
      ],
    );
  });

  group('LoadCampanasActivas', () {
    blocTest<CampanasBloc, CampanasState>(
      'emite [CampanasLoading, CampanasLoaded] cuando LoadCampanasActivas es exitoso',
      build: () {
        when(() => mockService.listarCampanasActivasInstance())
            .thenAnswer((_) async => campanaListMock);
        return campanasBloc;
      },
      act: (bloc) => bloc.add(const LoadCampanasActivas()),
      expect: () => [
        const CampanasLoading(),
        CampanasLoaded(
          campanas: campanaListMock,
          totalCount: 2,
          hasMore: false,
          filtroEstado: 'ACTIVA',
        ),
      ],
      verify: (_) {
        verify(() => mockService.listarCampanasActivasInstance()).called(1);
      },
    );
  });

  group('FilterCampanasByEstado', () {
    blocTest<CampanasBloc, CampanasState>(
      'filtra campañas por estado correctamente',
      build: () {
        when(() => mockService.listarCampanasInstance(estado: 'PAUSADA'))
            .thenAnswer((_) async => resultadoListaMock);
        return campanasBloc;
      },
      act: (bloc) => bloc.add(const FilterCampanasByEstado('PAUSADA')),
      expect: () => [
        const CampanasLoading(),
        CampanasLoaded(
          campanas: campanaListMock,
          totalCount: 2,
          hasMore: false,
          filtroEstado: 'PAUSADA',
        ),
      ],
    );
  });

  group('LoadMoreCampanas', () {
    blocTest<CampanasBloc, CampanasState>(
      'carga más campañas exitosamente cuando hay más páginas',
      build: () {
        // Primera página
        when(() => mockService.listarCampanasInstance(
          estado: any(named: 'estado'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => resultadoListaConPaginacionMock);

        // Segunda página
        when(() => mockService.listarCampanasInstance(
          estado: any(named: 'estado'),
          page: 2,
        )).thenAnswer((_) async => resultadoListaMock);

        return campanasBloc;
      },
      seed: () => CampanasLoaded(
        campanas: campanaListMock,
        totalCount: 10,
        hasMore: true,
        currentPage: 1,
        filtroEstado: 'ACTIVA',
      ),
      act: (bloc) => bloc.add(const LoadMoreCampanas()),
      expect: () => [
        CampanasLoadingMore(campanaListMock),
        CampanasLoaded(
          campanas: [...campanaListMock, ...campanaListMock],
          totalCount: 10,
          hasMore: false,
          currentPage: 2,
          filtroEstado: 'ACTIVA',
        ),
      ],
    );

    blocTest<CampanasBloc, CampanasState>(
      'no carga más campañas cuando no hay más páginas',
      build: () => campanasBloc,
      seed: () => CampanasLoaded(
        campanas: campanaListMock,
        totalCount: 2,
        hasMore: false,
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const LoadMoreCampanas()),
      expect: () => [],
    );

    blocTest<CampanasBloc, CampanasState>(
      'no carga más campañas cuando el estado no es CampanasLoaded',
      build: () => campanasBloc,
      seed: () => const CampanasInitial(),
      act: (bloc) => bloc.add(const LoadMoreCampanas()),
      expect: () => [],
    );

    blocTest<CampanasBloc, CampanasState>(
      'maneja error al cargar más campañas manteniendo las anteriores',
      build: () {
        when(() => mockService.listarCampanasInstance(
          estado: any(named: 'estado'),
          page: any(named: 'page'),
        )).thenThrow(Exception('Error de paginación'));
        return campanasBloc;
      },
      seed: () => CampanasLoaded(
        campanas: campanaListMock,
        totalCount: 10,
        hasMore: true,
        currentPage: 1,
        filtroEstado: 'ACTIVA',
      ),
      act: (bloc) => bloc.add(const LoadMoreCampanas()),
      expect: () => [
        CampanasLoadingMore(campanaListMock),
        CampanasError(
          'Exception: Error de paginación',
          previousCampanas: campanaListMock,
        ),
      ],
    );
  });

  group('Pruebas de integración con servicio', () {
    test('usa servicio inyectado cuando está disponible', () async {
      when(() => mockService.listarCampanasInstance())
          .thenAnswer((_) async => resultadoListaMock);

      final bloc = CampanasBloc(service: mockService);
      bloc.add(const LoadCampanas());

      await untilCalled(() => mockService.listarCampanasInstance());
      
      verify(() => mockService.listarCampanasInstance()).called(1);
      
      await bloc.close();
    });

    test('maneja correctamente la paginación con hasMore', () {
      final state = CampanasLoaded(
        campanas: campanaListMock,
        totalCount: 10,
        hasMore: true,
        currentPage: 1,
      );

      expect(state.hasMore, true);
      expect(state.currentPage, 1);
      expect(state.campanas.length, 2);
    });

    test('copyWith funciona correctamente', () {
      final original = CampanasLoaded(
        campanas: campanaListMock,
        totalCount: 10,
        hasMore: true,
        currentPage: 1,
        filtroEstado: 'ACTIVA',
      );

      final copia = original.copyWith(
        campanas: [campanaMock],
        totalCount: 1,
        hasMore: false,
        currentPage: 2,
      );

      expect(copia.campanas.length, 1);
      expect(copia.totalCount, 1);
      expect(copia.hasMore, false);
      expect(copia.currentPage, 2);
      expect(copia.filtroEstado, 'ACTIVA'); // Se mantiene el original
    });
  });
}