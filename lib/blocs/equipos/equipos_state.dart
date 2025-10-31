import 'package:equatable/equatable.dart';
import '../../models/equipos/equipo_model.dart';

/// Estados para el BLoC de equipos
abstract class EquiposState extends Equatable {
  const EquiposState();

  @override
  List<Object?> get props => [];
}

class EquiposInitial extends EquiposState {
  const EquiposInitial();
}

class EquiposLoading extends EquiposState {
  const EquiposLoading();
}

class EquiposLoaded extends EquiposState {
  final List<EquipoModel> equipos;
  final int totalCount;
  final bool hasMore;

  const EquiposLoaded({
    required this.equipos,
    required this.totalCount,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [equipos, totalCount, hasMore];
}

class EquipoDetailLoaded extends EquiposState {
  final EquipoModel equipo;

  const EquipoDetailLoaded(this.equipo);

  @override
  List<Object?> get props => [equipo];
}

class EquiposError extends EquiposState {
  final String message;

  const EquiposError(this.message);

  @override
  List<Object?> get props => [message];
}
