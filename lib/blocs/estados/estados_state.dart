import 'package:equatable/equatable.dart';
import '../../models/estado_agente_actual_model.dart';

/// Estados para el BLoC de estados de agentes
abstract class EstadosState extends Equatable {
  const EstadosState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class EstadosInitial extends EstadosState {
  const EstadosInitial();
}

/// Estado de carga
class EstadosLoading extends EstadosState {
  const EstadosLoading();
}

/// Estado de éxito al cargar el estado actual del agente
class EstadoActualLoaded extends EstadosState {
  final EstadoAgenteActualModel estadoActual;
  final DateTime timestamp;

  const EstadoActualLoaded({
    required this.estadoActual,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [estadoActual, timestamp];
}

/// Estado de éxito al cargar agentes disponibles
class AgentesDisponiblesLoaded extends EstadosState {
  final List<EstadoAgenteActualModel> agentes;

  const AgentesDisponiblesLoaded({
    required this.agentes,
  });

  @override
  List<Object?> get props => [agentes];
}

/// Estado de éxito al cargar todos los estados disponibles
class TodosLosEstadosLoaded extends EstadosState {
  final List<EstadoAgenteActualModel> estados;

  const TodosLosEstadosLoaded(this.estados);

  @override
  List<Object?> get props => [estados];
}

/// Estado de error
class EstadosError extends EstadosState {
  final String message;
  final EstadoAgenteActualModel? previousEstado;

  const EstadosError(this.message, {this.previousEstado});

  @override
  List<Object?> get props => [message, previousEstado];
}
