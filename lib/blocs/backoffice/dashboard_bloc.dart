import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/backoffice/dashboard_service.dart';

// ==================== EVENTOS ====================
abstract class DashboardEvent {}

/// Evento para cargar las estadísticas del dashboard
class CargarDashboard extends DashboardEvent {}

/// Evento para refrescar las estadísticas
class RefrescarDashboard extends DashboardEvent {}

// ==================== ESTADOS ====================
abstract class DashboardState {}

/// Estado inicial
class DashboardInitial extends DashboardState {}

/// Estado de carga
class DashboardCargando extends DashboardState {}

/// Estado cuando los datos se cargaron exitosamente
class DashboardCargado extends DashboardState {
  final DashboardStats stats;

  DashboardCargado(this.stats);
}

/// Estado de error
class DashboardError extends DashboardState {
  final String mensaje;

  DashboardError(this.mensaje);
}

// ==================== BLOC ====================
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService _dashboardService;

  DashboardBloc(this._dashboardService) : super(DashboardInitial()) {
    on<CargarDashboard>(_onCargarDashboard);
    on<RefrescarDashboard>(_onRefrescarDashboard);
  }

  /// Maneja el evento de cargar dashboard
  Future<void> _onCargarDashboard(
    CargarDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardCargando());
    
    try {
      final stats = await _dashboardService.fetchDashboardStats();
      
      if (stats != null) {
        emit(DashboardCargado(stats));
      } else {
        emit(DashboardError("No se pudieron cargar las estadísticas"));
      }
    } catch (e) {
      emit(DashboardError("Error de conexión: $e"));
    }
  }

  /// Maneja el evento de refrescar dashboard
  Future<void> _onRefrescarDashboard(
    RefrescarDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // No mostramos loading al refrescar, mantenemos los datos actuales
    try {
      final stats = await _dashboardService.fetchDashboardStats();
      
      if (stats != null) {
        emit(DashboardCargado(stats));
      } else {
        emit(DashboardError("No se pudieron refrescar las estadísticas"));
      }
    } catch (e) {
      emit(DashboardError("Error de conexión: $e"));
    }
  }
}
