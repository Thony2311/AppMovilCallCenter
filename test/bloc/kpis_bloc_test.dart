// test/unit/bloc/kpis_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:call_center_application/blocs/kpis/kpis_event.dart';
import 'package:call_center_application/blocs/kpis/kpis_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:call_center_application/blocs/kpis/kpis_bloc.dart';
import 'package:call_center_application/services/kpis/kpis_service.dart';
import 'package:call_center_application/models/kpis/kpi_agente_list_model.dart';
import 'package:call_center_application/models/kpis/kpi_agente_detalle_model.dart';
import 'package:call_center_application/models/kpis/kpi_overview_model.dart';

// Mocks para los modelos (creados basados en la estructura del BLoC)
class MockKPIAgenteListModel extends Mock implements KPIAgenteListModel {}
class MockKPIAgenteDetalleModel extends Mock implements KPIAgenteDetalleModel {
  @override
  String get agenteId => 'test_agent_123';
  
  @override
  String get agenteNombre => 'Test Agent';
}

class MockKPIOverviewModel extends Mock implements KPIOverviewModel {
  @override
  String get tipoUsuario => 'agente';
}

class MockKPIsService extends Mock implements KPIsServiceInterface {}

void main() {
  late MockKPIsService mockKPIsService;
  late KPIsBloc kpisBloc;

setUp(() {
  mockKPIsService = MockKPIsService();
  kpisBloc = KPIsBloc(service: mockKPIsService);
  
  // 🔥 CORRECCIÓN: Configurar fallback values para manejar parámetros nulos
  registerFallbackValue(DateTime.now());
  registerFallbackValue(const LoadKPIAgentes());
  registerFallbackValue(const LoadKPIAgenteDetalle(documentoId: 'test'));
  registerFallbackValue(const LoadKPIOverview());
  registerFallbackValue(const RefreshKPIs());
  registerFallbackValue(const ChangeKPIRango(rango: 'test'));
});

  tearDown(() {
    kpisBloc.close();
  });

  group('KPIsBloc - Pruebas Unitarias', () {
    // ========== PRUEBAS PARA LoadKPIAgentes ==========
    blocTest<KPIsBloc, KPIsState>(
      'debe emitir [KPIsLoading, KPIsError] cuando LoadKPIAgentes falla',
      build: () {
        when(() => mockKPIsService.listarAgentesInstance())
            .thenThrow(Exception('Error de red'));
        
        return kpisBloc;
      },
      act: (bloc) => bloc.add(const LoadKPIAgentes()),
      expect: () => [
        const KPIsLoading(),
        isA<KPIsError>(),
      ],
    );

    blocTest<KPIsBloc, KPIsState>(
      'debe pasar los filtros correctos al servicio en LoadKPIAgentes',
      build: () {
        when(() => mockKPIsService.listarAgentesInstance(
          role: 'agent',
          isActive: true,
          search: 'test',
        )).thenAnswer((_) async => [MockKPIAgenteListModel()]);
        
        return kpisBloc;
      },
      act: (bloc) => bloc.add(const LoadKPIAgentes(
        role: 'agent',
        isActive: true,
        search: 'test',
      )),
      expect: () => [
        const KPIsLoading(),
        isA<KPIAgentesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockKPIsService.listarAgentesInstance(
          role: 'agent',
          isActive: true,
          search: 'test',
        )).called(1);
      },
    );

    // ========== PRUEBAS PARA LoadKPIAgenteDetalle ==========
   blocTest<KPIsBloc, KPIsState>(
  'debe emitir [KPIsLoading, KPIAgenteDetalleLoaded] cuando LoadKPIAgenteDetalle es exitoso',
  build: () {
    when(() => mockKPIsService.obtenerKPIAgenteInstance(
      documentoId: any(named: 'documentoId', that: equals('test_agent_123')),
      fechaDesde: any(named: 'fechaDesde'),
      fechaHasta: any(named: 'fechaHasta'),
      rango: any(named: 'rango'),
    )).thenAnswer((_) async => MockKPIAgenteDetalleModel());
    
    return kpisBloc;
  },
  act: (bloc) => bloc.add(const LoadKPIAgenteDetalle(
    documentoId: 'test_agent_123',
  )),
  expect: () => [
    const KPIsLoading(),
    isA<KPIAgenteDetalleLoaded>(),
  ],
  verify: (_) {
    verify(() => mockKPIsService.obtenerKPIAgenteInstance(
      documentoId: 'test_agent_123',
      fechaDesde: null,
      fechaHasta: null,
      rango: 'hoy',
    )).called(1);
  },
);
    // ========== PRUEBAS PARA LoadKPIOverview ==========
    blocTest<KPIsBloc, KPIsState>(
      'debe emitir [KPIsLoading, KPIOverviewLoaded] cuando LoadKPIOverview es exitoso',
      build: () {
        when(() => mockKPIsService.obtenerOverviewInstance(
          fechaDesde: any(named: 'fechaDesde'),
          fechaHasta: any(named: 'fechaHasta'),
          campanaId: any(named: 'campanaId'),
          equipoId: any(named: 'equipoId'),
        )).thenAnswer((_) async => MockKPIOverviewModel());
        
        return kpisBloc;
      },
      act: (bloc) => bloc.add(const LoadKPIOverview()),
      expect: () => [
        const KPIsLoading(),
        isA<KPIOverviewLoaded>(),
      ],
      verify: (_) {
        verify(() => mockKPIsService.obtenerOverviewInstance()).called(1);
      },
    );

    // ========== PRUEBAS PARA RefreshKPIs ==========
    blocTest<KPIsBloc, KPIsState>(
      'debe actualizar KPIAgenteDetalleLoaded en RefreshKPIs exitoso',
      build: () {
        when(() => mockKPIsService.obtenerKPIAgenteInstance(
          documentoId: any(named: 'documentoId'),
        )).thenAnswer((_) async => MockKPIAgenteDetalleModel());
        
        // Iniciar con estado de detalle cargado
        kpisBloc.emit(KPIAgenteDetalleLoaded(
          detalle: MockKPIAgenteDetalleModel(),
          timestamp: DateTime.now(),
        ));
        
        return kpisBloc;
      },
      act: (bloc) => bloc.add(const RefreshKPIs()),
      expect: () => [
        isA<KPIAgenteDetalleLoaded>(),
      ],
      verify: (_) {
        verify(() => mockKPIsService.obtenerKPIAgenteInstance(
          documentoId: 'test_agent_123',
        )).called(1);
      },
    );

    blocTest<KPIsBloc, KPIsState>(
      'debe mantener estado anterior en RefreshKPIs con error',
      build: () {
        when(() => mockKPIsService.obtenerKPIAgenteInstance(
          documentoId: any(named: 'documentoId'),
        )).thenThrow(Exception('Error de refresco'));
        
        final previousState = KPIAgenteDetalleLoaded(
          detalle: MockKPIAgenteDetalleModel(),
          timestamp: DateTime.now(),
        );
        
        kpisBloc.emit(previousState);
        
        return kpisBloc;
      },
      act: (bloc) => bloc.add(const RefreshKPIs()),
      expect: () => [
        isA<KPIsError>()
          .having((error) => error.previousState, 'debe tener estado anterior', isA<KPIAgenteDetalleLoaded>()),
      ],
    );

    // ========== PRUEBAS PARA ChangeKPIRango ==========
    blocTest<KPIsBloc, KPIsState>(
      'debe cambiar rango exitosamente en KPIOverviewLoaded',
      build: () {
        when(() => mockKPIsService.obtenerOverviewInstance(
          fechaDesde: any(named: 'fechaDesde'),
          fechaHasta: any(named: 'fechaHasta'),
        )).thenAnswer((_) async => MockKPIOverviewModel());
        
        // Iniciar con estado overview cargado
        kpisBloc.emit(KPIOverviewLoaded(
          overview: MockKPIOverviewModel(),
          timestamp: DateTime.now(),
          rangoActual: 'hoy',
        ));
        
        return kpisBloc;
      },
      act: (bloc) => bloc.add(ChangeKPIRango(
        rango: 'semana',
        fechaDesde: DateTime(2024, 1, 1),
        fechaHasta: DateTime(2024, 1, 7),
      )),
      expect: () => [
        const KPIsLoading(),
        isA<KPIOverviewLoaded>()
          .having((state) => state.rangoActual, 'rangoActual', 'semana'),
      ],
    );

    blocTest<KPIsBloc, KPIsState>(
      'no debe hacer nada en ChangeKPIRango si no está en KPIOverviewLoaded',
      build: () => kpisBloc,
      act: (bloc) => bloc.add(const ChangeKPIRango(rango: 'semana')),
      expect: () => [],
    );

    // ========== PRUEBAS DE MANEJO DE ERRORES ==========
    blocTest<KPIsBloc, KPIsState>(
      'debe manejar errores en todos los eventos de carga',
      build: () {
        when(() => mockKPIsService.obtenerOverviewInstance())
            .thenThrow(Exception('Error genérico'));
        
        return kpisBloc;
      },
      act: (bloc) => bloc.add(const LoadKPIOverview()),
      expect: () => [
        const KPIsLoading(),
        isA<KPIsError>()
          .having((error) => error.message, 'message', contains('Error genérico')),
      ],
    );
    // ========== PRUEBAS DE SERVICE FALLBACK ==========
        blocTest<KPIsBloc, KPIsState>(
      'debe usar servicio inyectado cuando está disponible',
      build: () {
        final testBloc = KPIsBloc(service: mockKPIsService);
        
        when(() => mockKPIsService.listarAgentesInstance(
          role: any(named: 'role'),
          isActive: any(named: 'isActive'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => [MockKPIAgenteListModel()]);
        
        return testBloc;
      },
      act: (bloc) => bloc.add(const LoadKPIAgentes()),
      expect: () => [
        const KPIsLoading(),
        isA<KPIAgentesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockKPIsService.listarAgentesInstance(
          role: null,
          isActive: null,
          search: null,
        )).called(1);
      },
    );
  });

  group('KPIsBloc - Edge Cases', () {
    blocTest<KPIsBloc, KPIsState>(
      'debe manejar lista vacía de agentes',
      build: () {
        when(() => mockKPIsService.listarAgentesInstance())
            .thenAnswer((_) async => []);
        
        return kpisBloc;
      },
      act: (bloc) => bloc.add(const LoadKPIAgentes()),
      expect: () => [
        const KPIsLoading(),
        isA<KPIAgentesLoaded>()
          .having((state) => state.agentes, 'agentes vacíos', isEmpty),
      ],
    );

    blocTest<KPIsBloc, KPIsState>(
      'debe manejar RefreshKPIs en estado inicial sin errores',
      build: () => kpisBloc,
      act: (bloc) => bloc.add(const RefreshKPIs()),
      expect: () => [], // No debe emitir nuevos estados
    );

    blocTest<KPIsBloc, KPIsState>(
      'debe manejar múltiples eventos secuencialmente',
      build: () {
        when(() => mockKPIsService.listarAgentesInstance())
            .thenAnswer((_) async => [MockKPIAgenteListModel()]);
        
        when(() => mockKPIsService.obtenerOverviewInstance())
            .thenAnswer((_) async => MockKPIOverviewModel());
        
        return kpisBloc;
      },
      act: (bloc) {
        bloc.add(const LoadKPIAgentes());
        bloc.add(const LoadKPIOverview());
      },
      expect: () => [
        const KPIsLoading(),
        isA<KPIAgentesLoaded>(),
        const KPIsLoading(),
        isA<KPIOverviewLoaded>(),
      ],
    );
  });
}