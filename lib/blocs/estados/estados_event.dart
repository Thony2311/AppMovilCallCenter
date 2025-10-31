import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de estados de agentes
abstract class EstadosEvent extends Equatable {
  const EstadosEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el estado actual del agente autenticado
class LoadEstadoActual extends EstadosEvent {
  const LoadEstadoActual();
}

/// Evento para cargar los agentes disponibles
class LoadAgentesDisponibles extends EstadosEvent {
  const LoadAgentesDisponibles();
}

/// Evento para cargar todos los estados disponibles
class LoadTodosLosEstados extends EstadosEvent {
  const LoadTodosLosEstados();
}

/// Evento para refrescar el estado actual (polling)
class RefreshEstado extends EstadosEvent {
  const RefreshEstado();
}
