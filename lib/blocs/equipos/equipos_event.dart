import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de equipos
abstract class EquiposEvent extends Equatable {
  const EquiposEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la lista de equipos
class LoadEquipos extends EquiposEvent {
  final int? campana;
  final String? coordinador;
  final bool? isActive;
  final int page;

  const LoadEquipos({
    this.campana,
    this.coordinador,
    this.isActive,
    this.page = 1,
  });

  @override
  List<Object?> get props => [campana, coordinador, isActive, page];
}

/// Evento para cargar un equipo específico
class LoadEquipoById extends EquiposEvent {
  final int equipoId;

  const LoadEquipoById(this.equipoId);

  @override
  List<Object?> get props => [equipoId];
}

/// Evento para cargar equipos activos
class LoadEquiposActivos extends EquiposEvent {
  const LoadEquiposActivos();
}

/// Evento para refrescar la lista
class RefreshEquipos extends EquiposEvent {
  const RefreshEquipos();
}
