import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/equipos/equipo_model.dart';
import '../../services/equipos_service.dart';
import '../../utils/app_logger.dart';
import 'equipos_event.dart';
import 'equipos_state.dart';

/// BLoC para gestionar el estado de los equipos
class EquiposBloc extends Bloc<EquiposEvent, EquiposState> {
  EquiposBloc() : super(const EquiposInitial()) {
    on<LoadEquipos>(_onLoadEquipos);
    on<LoadEquipoById>(_onLoadEquipoById);
    on<LoadEquiposActivos>(_onLoadEquiposActivos);
    on<RefreshEquipos>(_onRefreshEquipos);
  }

  Future<void> _onLoadEquipos(
    LoadEquipos event,
    Emitter<EquiposState> emit,
  ) async {
    try {
      emit(const EquiposLoading());

      final resultado = await EquiposService.listarEquipos(
        campana: event.campana,
        coordinador: event.coordinador,
        isActive: event.isActive,
        page: event.page,
      );

      final equipos = (resultado['equipos'] as List).cast<EquipoModel>();
      final count = resultado['count'] as int;
      final hasMore = resultado['next'] != null;

      emit(EquiposLoaded(
        equipos: equipos,
        totalCount: count,
        hasMore: hasMore,
      ));

      AppLogger.info('✅ Equipos cargados: ${equipos.length}');
    } catch (e) {
      AppLogger.error('❌ Error al cargar equipos: $e');
      emit(EquiposError(e.toString()));
    }
  }

  Future<void> _onLoadEquipoById(
    LoadEquipoById event,
    Emitter<EquiposState> emit,
  ) async {
    try {
      emit(const EquiposLoading());
      final equipo = await EquiposService.obtenerEquipo(event.equipoId);
      emit(EquipoDetailLoaded(equipo));
    } catch (e) {
      AppLogger.error('❌ Error al cargar equipo: $e');
      emit(EquiposError(e.toString()));
    }
  }

  Future<void> _onLoadEquiposActivos(
    LoadEquiposActivos event,
    Emitter<EquiposState> emit,
  ) async {
    try {
      emit(const EquiposLoading());
      final equipos = await EquiposService.listarEquiposActivos();

      emit(EquiposLoaded(
        equipos: equipos,
        totalCount: equipos.length,
        hasMore: false,
      ));
    } catch (e) {
      emit(EquiposError(e.toString()));
    }
  }

  Future<void> _onRefreshEquipos(
    RefreshEquipos event,
    Emitter<EquiposState> emit,
  ) async {
    add(const LoadEquipos());
  }
}
