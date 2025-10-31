import 'package:equatable/equatable.dart';
import '../../models/kpis/kpi_agente_list_model.dart';
import '../../models/kpis/kpi_agente_detalle_model.dart';
import '../../models/kpis/kpi_overview_model.dart';

/// Estados para el BLoC de KPIs
abstract class KPIsState extends Equatable {
  const KPIsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class KPIsInitial extends KPIsState {
  const KPIsInitial();
}

/// Estado de carga
class KPIsLoading extends KPIsState {
  const KPIsLoading();
}

/// Estado de éxito al cargar lista de agentes
class KPIAgentesLoaded extends KPIsState {
  final List<KPIAgenteListModel> agentes;
  final String? filtroRole;
  final String? filtroSearch;

  const KPIAgentesLoaded({
    required this.agentes,
    this.filtroRole,
    this.filtroSearch,
  });

  @override
  List<Object?> get props => [agentes, filtroRole, filtroSearch];
}

/// Estado de éxito al cargar KPI detallado de agente
class KPIAgenteDetalleLoaded extends KPIsState {
  final KPIAgenteDetalleModel detalle;
  final DateTime timestamp;

  const KPIAgenteDetalleLoaded({
    required this.detalle,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [detalle, timestamp];
}

/// Estado de éxito al cargar overview
class KPIOverviewLoaded extends KPIsState {
  final KPIOverviewModel overview;
  final DateTime timestamp;
  final String rangoActual;

  const KPIOverviewLoaded({
    required this.overview,
    required this.timestamp,
    required this.rangoActual,
  });

  @override
  List<Object?> get props => [overview, timestamp, rangoActual];

  KPIOverviewLoaded copyWith({
    KPIOverviewModel? overview,
    DateTime? timestamp,
    String? rangoActual,
  }) {
    return KPIOverviewLoaded(
      overview: overview ?? this.overview,
      timestamp: timestamp ?? this.timestamp,
      rangoActual: rangoActual ?? this.rangoActual,
    );
  }
}

/// Estado de éxito al cargar KPI de coordinador
class KPICoordinadorLoaded extends KPIsState {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const KPICoordinadorLoaded({
    required this.data,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [data, timestamp];
}

/// Estado de error
class KPIsError extends KPIsState {
  final String message;
  final KPIsState? previousState;

  const KPIsError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}
