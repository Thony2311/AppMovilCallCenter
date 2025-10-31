import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de KPIs
abstract class KPIsEvent extends Equatable {
  const KPIsEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar lista de agentes KPI
class LoadKPIAgentes extends KPIsEvent {
  final String? role;
  final bool? isActive;
  final String? search;

  const LoadKPIAgentes({
    this.role,
    this.isActive,
    this.search,
  });

  @override
  List<Object?> get props => [role, isActive, search];
}

/// Evento para cargar KPI detallado de un agente
class LoadKPIAgenteDetalle extends KPIsEvent {
  final String documentoId;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final String? rango;

  const LoadKPIAgenteDetalle({
    required this.documentoId,
    this.fechaDesde,
    this.fechaHasta,
    this.rango = 'hoy',
  });

  @override
  List<Object?> get props => [documentoId, fechaDesde, fechaHasta, rango];
}

/// Evento para cargar el overview de KPIs
class LoadKPIOverview extends KPIsEvent {
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final String? rango;
  final int? campanaId;
  final int? equipoId;

  const LoadKPIOverview({
    this.fechaDesde,
    this.fechaHasta,
    this.rango = 'hoy',
    this.campanaId,
    this.equipoId,
  });

  @override
  List<Object?> get props => [fechaDesde, fechaHasta, rango, campanaId, equipoId];
}

/// Evento para cargar KPIs detallados de coordinador
class LoadKPICoordinador extends KPIsEvent {
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final int? equipoId;

  const LoadKPICoordinador({
    this.fechaDesde,
    this.fechaHasta,
    this.equipoId,
  });

  @override
  List<Object?> get props => [fechaDesde, fechaHasta, equipoId];
}

/// Evento para refrescar los KPIs actuales
class RefreshKPIs extends KPIsEvent {
  const RefreshKPIs();
}

/// Evento para cambiar el rango de fechas
class ChangeKPIRango extends KPIsEvent {
  final String rango;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  const ChangeKPIRango({
    required this.rango,
    this.fechaDesde,
    this.fechaHasta,
  });

  @override
  List<Object?> get props => [rango, fechaDesde, fechaHasta];
}
