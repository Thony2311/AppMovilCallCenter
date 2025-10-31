import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/clientes/cliente_model.dart';
import '../../services/clientes_service.dart';
import '../../utils/app_logger.dart';
import 'clientes_event.dart';
import 'clientes_state.dart';

/// BLoC para gestionar el estado de los clientes
class ClientesBloc extends Bloc<ClientesEvent, ClientesState> {
  ClientesBloc() : super(const ClientesInitial()) {
    on<LoadClientes>(_onLoadClientes);
    on<LoadClienteById>(_onLoadClienteById);
    on<SearchClientes>(_onSearchClientes);
    on<LoadMoreClientes>(_onLoadMoreClientes);
    on<RefreshClientes>(_onRefreshClientes);
  }

  Future<void> _onLoadClientes(
    LoadClientes event,
    Emitter<ClientesState> emit,
  ) async {
    try {
      emit(const ClientesLoading());

      final resultado = await ClientesService.listarClientes(
        campana: event.campana,
        search: event.search,
        baseDatos: event.baseDatos,
        page: event.page,
      );

      final clientes = (resultado['clientes'] as List).cast<ClienteModel>();
      final count = resultado['count'] as int;
      final hasMore = resultado['next'] != null;

      emit(ClientesLoaded(
        clientes: clientes,
        totalCount: count,
        hasMore: hasMore,
        currentPage: event.page,
        filtroCampana: event.campana,
        filtroSearch: event.search,
      ));

      AppLogger.info('✅ Clientes cargados: ${clientes.length}');
    } catch (e) {
      AppLogger.error('❌ Error al cargar clientes: $e');
      emit(ClientesError(e.toString()));
    }
  }

  Future<void> _onLoadClienteById(
    LoadClienteById event,
    Emitter<ClientesState> emit,
  ) async {
    try {
      emit(const ClientesLoading());
      final cliente = await ClientesService.obtenerCliente(event.clienteId);
      emit(ClienteDetailLoaded(cliente));
    } catch (e) {
      AppLogger.error('❌ Error al cargar cliente: $e');
      emit(ClientesError(e.toString()));
    }
  }

  Future<void> _onSearchClientes(
    SearchClientes event,
    Emitter<ClientesState> emit,
  ) async {
    try {
      emit(const ClientesLoading());
      final clientes = await ClientesService.buscarClientes(
        event.termino,
        campanaId: event.campanaId,
      );

      emit(ClientesLoaded(
        clientes: clientes,
        totalCount: clientes.length,
        hasMore: false,
        filtroSearch: event.termino,
        filtroCampana: event.campanaId,
      ));
    } catch (e) {
      emit(ClientesError(e.toString()));
    }
  }

  Future<void> _onLoadMoreClientes(
    LoadMoreClientes event,
    Emitter<ClientesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ClientesLoaded || !currentState.hasMore) return;

    try {
      emit(ClientesLoadingMore(currentState.clientes));

      final nextPage = currentState.currentPage + 1;
      final resultado = await ClientesService.listarClientes(
        campana: currentState.filtroCampana,
        search: currentState.filtroSearch,
        page: nextPage,
      );

      final newClientes = (resultado['clientes'] as List).cast<ClienteModel>();
      final allClientes = [...currentState.clientes, ...newClientes];

      emit(currentState.copyWith(
        clientes: allClientes,
        hasMore: resultado['next'] != null,
        currentPage: nextPage,
      ));
    } catch (e) {
      emit(ClientesError(e.toString()));
    }
  }

  Future<void> _onRefreshClientes(
    RefreshClientes event,
    Emitter<ClientesState> emit,
  ) async {
    final currentState = state;
    if (currentState is ClientesLoaded) {
      add(LoadClientes(
        campana: currentState.filtroCampana,
        search: currentState.filtroSearch,
      ));
    } else {
      add(const LoadClientes());
    }
  }
}
