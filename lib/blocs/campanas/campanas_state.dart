import 'package:equatable/equatable.dart';
import '../../models/campanas/campana_model.dart';

/// Estados para el BLoC de campañas
abstract class CampanasState extends Equatable {
  const CampanasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CampanasInitial extends CampanasState {
  const CampanasInitial();
}

/// Estado de carga
class CampanasLoading extends CampanasState {
  const CampanasLoading();
}

/// Estado de éxito al cargar lista de campañas
class CampanasLoaded extends CampanasState {
  final List<CampanaModel> campanas;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
  final String? filtroEstado;

  const CampanasLoaded({
    required this.campanas,
    required this.totalCount,
    required this.hasMore,
    this.currentPage = 1,
    this.filtroEstado,
  });

  @override
  List<Object?> get props => [campanas, totalCount, hasMore, currentPage, filtroEstado];

  /// Crea una copia con campos actualizados
  CampanasLoaded copyWith({
    List<CampanaModel>? campanas,
    int? totalCount,
    bool? hasMore,
    int? currentPage,
    String? filtroEstado,
  }) {
    return CampanasLoaded(
      campanas: campanas ?? this.campanas,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filtroEstado: filtroEstado ?? this.filtroEstado,
    );
  }
}

/// Estado de carga de más campañas (paginación)
class CampanasLoadingMore extends CampanasState {
  final List<CampanaModel> currentCampanas;

  const CampanasLoadingMore(this.currentCampanas);

  @override
  List<Object?> get props => [currentCampanas];
}

/// Estado de éxito al cargar una campaña individual
class CampanaDetailLoaded extends CampanasState {
  final CampanaModel campana;

  const CampanaDetailLoaded(this.campana);

  @override
  List<Object?> get props => [campana];
}

/// Estado de error
class CampanasError extends CampanasState {
  final String message;
  final List<CampanaModel>? previousCampanas;

  const CampanasError(this.message, {this.previousCampanas});

  @override
  List<Object?> get props => [message, previousCampanas];
}
