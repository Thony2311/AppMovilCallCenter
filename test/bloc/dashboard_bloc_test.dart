import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:call_center_application/services/backoffice/dashboard_service.dart';
import 'package:call_center_application/blocs/backoffice/dashboard_bloc.dart';
/// ===== MOCKS =====

class MockDashboardService extends Mock implements DashboardService {}

void main() {
  late DashboardBloc dashboardBloc;
  late MockDashboardService mockService;

  // Datos falsos para simular respuesta del backend
  final fakeStats = DashboardStats(
    llamadasReportadas: 12,
    ventasAuditadas: 5,
    ventasPorAuditar: 3,
    totalVentas: 8,
    montoTotal: 45000.5,
  );

  setUp(() {
    mockService = MockDashboardService();
    dashboardBloc = DashboardBloc(mockService);
  });

  tearDown(() {
    dashboardBloc.close();
  });

  group('DashboardBloc Tests', () {
    test('Estado inicial debe ser DashboardInitial', () {
      expect(dashboardBloc.state, isA<DashboardInitial>());
    });

    blocTest<DashboardBloc, DashboardState>(
      'Emite [DashboardCargando, DashboardCargado] cuando fetchDashboardStats retorna datos',
      build: () {
        when(() => mockService.fetchDashboardStats())
            .thenAnswer((_) async => fakeStats);
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(CargarDashboard()),
      expect: () => [
        isA<DashboardCargando>(),
        isA<DashboardCargado>().having((s) => s.stats, 'stats', fakeStats),
      ],
      verify: (_) {
        verify(() => mockService.fetchDashboardStats()).called(1);
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'Emite [DashboardCargando, DashboardError] cuando fetchDashboardStats retorna null',
      build: () {
        when(() => mockService.fetchDashboardStats()).thenAnswer((_) async => null);
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(CargarDashboard()),
      expect: () => [
        isA<DashboardCargando>(),
        isA<DashboardError>(),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'Emite [DashboardCargado] al refrescar dashboard correctamente',
      build: () {
        when(() => mockService.fetchDashboardStats())
            .thenAnswer((_) async => fakeStats);
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(RefrescarDashboard()),
      expect: () => [
        isA<DashboardCargado>().having((s) => s.stats, 'stats', fakeStats),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'Emite [DashboardError] al refrescar con error en fetchDashboardStats',
      build: () {
        when(() => mockService.fetchDashboardStats())
            .thenThrow(Exception('Falla de red'));
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(RefrescarDashboard()),
      expect: () => [
        isA<DashboardError>(),
      ],
    );
  });
}
