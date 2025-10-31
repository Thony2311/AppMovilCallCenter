import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de campañas
abstract class CampanasEvent extends Equatable {
  const CampanasEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la lista de campañas
class LoadCampanas extends CampanasEvent {
  final String? estado;
  final String? jefeCampana;
  final int? centro;
  final int page;

  const LoadCampanas({
    this.estado,
    this.jefeCampana,
    this.centro,
    this.page = 1,
  });

  @override
  List<Object?> get props => [estado, jefeCampana, centro, page];
}

/// Evento para cargar una campaña específica por ID
class LoadCampanaById extends CampanasEvent {
  final int campanaId;

  const LoadCampanaById(this.campanaId);

  @override
  List<Object?> get props => [campanaId];
}

/// Evento para cargar solo campañas activas
class LoadCampanasActivas extends CampanasEvent {
  const LoadCampanasActivas();
}

/// Evento para filtrar campañas por estado
class FilterCampanasByEstado extends CampanasEvent {
  final String estado;

  const FilterCampanasByEstado(this.estado);

  @override
  List<Object?> get props => [estado];
}

/// Evento para cargar más campañas (paginación)
class LoadMoreCampanas extends CampanasEvent {
  const LoadMoreCampanas();
}

/// Evento para refrescar la lista de campañas
class RefreshCampanas extends CampanasEvent {
  const RefreshCampanas();
}
