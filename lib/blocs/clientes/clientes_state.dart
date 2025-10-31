import 'package:equatable/equatable.dart';
import '../../models/clientes/cliente_model.dart';

/// Estados para el BLoC de clientes
abstract class ClientesState extends Equatable {
  const ClientesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ClientesInitial extends ClientesState {
  const ClientesInitial();
}

/// Estado de carga
class ClientesLoading extends ClientesState {
  const ClientesLoading();
}

/// Estado de éxito
class ClientesLoaded extends ClientesState {
  final List<ClienteModel> clientes;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
  final int? filtroCampana;
  final String? filtroSearch;

  const ClientesLoaded({
    required this.clientes,
    required this.totalCount,
    required this.hasMore,
    this.currentPage = 1,
    this.filtroCampana,
    this.filtroSearch,
  });

  @override
  List<Object?> get props => [clientes, totalCount, hasMore, currentPage, filtroCampana, filtroSearch];

  ClientesLoaded copyWith({
    List<ClienteModel>? clientes,
    int? totalCount,
    bool? hasMore,
    int? currentPage,
  }) {
    return ClientesLoaded(
      clientes: clientes ?? this.clientes,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filtroCampana: filtroCampana,
      filtroSearch: filtroSearch,
    );
  }
}

/// Estado de carga de más clientes
class ClientesLoadingMore extends ClientesState {
  final List<ClienteModel> currentClientes;

  const ClientesLoadingMore(this.currentClientes);

  @override
  List<Object?> get props => [currentClientes];
}

/// Estado de detalle de cliente
class ClienteDetailLoaded extends ClientesState {
  final ClienteModel cliente;

  const ClienteDetailLoaded(this.cliente);

  @override
  List<Object?> get props => [cliente];
}

/// Estado de error
class ClientesError extends ClientesState {
  final String message;

  const ClientesError(this.message);

  @override
  List<Object?> get props => [message];
}
