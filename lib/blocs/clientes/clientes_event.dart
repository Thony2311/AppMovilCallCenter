import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de clientes
abstract class ClientesEvent extends Equatable {
  const ClientesEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la lista de clientes
class LoadClientes extends ClientesEvent {
  final int? campana;
  final String? search;
  final int? baseDatos;
  final int page;

  const LoadClientes({
    this.campana,
    this.search,
    this.baseDatos,
    this.page = 1,
  });

  @override
  List<Object?> get props => [campana, search, baseDatos, page];
}

/// Evento para cargar un cliente específico
class LoadClienteById extends ClientesEvent {
  final int clienteId;

  const LoadClienteById(this.clienteId);

  @override
  List<Object?> get props => [clienteId];
}

/// Evento para buscar clientes
class SearchClientes extends ClientesEvent {
  final String termino;
  final int? campanaId;

  const SearchClientes(this.termino, {this.campanaId});

  @override
  List<Object?> get props => [termino, campanaId];
}

/// Evento para cargar más clientes (paginación)
class LoadMoreClientes extends ClientesEvent {
  const LoadMoreClientes();
}

/// Evento para refrescar la lista
class RefreshClientes extends ClientesEvent {
  const RefreshClientes();
}
