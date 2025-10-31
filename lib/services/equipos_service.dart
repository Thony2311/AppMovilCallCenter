import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/auth_manager.dart';
import '../models/equipos/equipo_model.dart';
import '../utils/app_logger.dart';

/// Servicio para gestionar operaciones relacionadas con equipos
/// 
/// Proporciona métodos para listar y obtener información de equipos
/// de agentes asignados a campañas del call center.
class EquiposService {
  /// Lista todos los equipos con filtros opcionales
  /// 
  /// [campana]: Filtrar por ID de campaña
  /// [coordinador]: Filtrar por documento del coordinador
  /// [isActive]: Filtrar por equipos activos/inactivos
  /// [page]: Número de página para paginación
  /// 
  /// Returns: Lista de equipos y total de resultados
  /// Throws: Exception si hay error en la petición
  static Future<Map<String, dynamic>> listarEquipos({
    int? campana,
    String? coordinador,
    bool? isActive,
    int page = 1,
  }) async {
    try {
      final token = AuthManager().accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación disponible');
      }

      // Construir query parameters
      final Map<String, dynamic> queryParams = {'page': page};
      if (campana != null) {
        queryParams['campana'] = campana;
      }
      if (coordinador != null && coordinador.isNotEmpty) {
        queryParams['coordinador'] = coordinador;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final url = ApiConfig.buildUrl(
        ApiConfig.equiposEndpoint,
        queryParams: queryParams,
      );

      AppLogger.info('👨‍👩‍👧‍👦 Obteniendo lista de equipos desde: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers(token: token),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final List<dynamic> results = (jsonData['results'] as List<dynamic>?) ?? [];
        final equipos = results
            .map((json) => EquipoModel.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('✅ Se obtuvieron ${equipos.length} equipos exitosamente');

        return {
          'count': jsonData['count'] ?? 0,
          'next': jsonData['next'],
          'previous': jsonData['previous'],
          'equipos': equipos,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver los equipos');
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Error al obtener equipos';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Error al listar equipos: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles completos de un equipo específico
  /// 
  /// [equipoId]: ID del equipo a consultar
  /// 
  /// Returns: Modelo completo del equipo con sus agentes
  /// Throws: Exception si hay error en la petición o no se encuentra
  static Future<EquipoModel> obtenerEquipo(int equipoId) async {
    try {
      final token = AuthManager().accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación disponible');
      }

      final url = '${ApiConfig.equipoDetailEndpoint}/$equipoId/';
      AppLogger.info('👨‍👩‍👧‍👦 Obteniendo equipo #$equipoId desde: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers(token: token),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final equipo = EquipoModel.fromJson(jsonData);
        
        AppLogger.info('✅ Equipo "${equipo.nombre}" obtenido exitosamente (${equipo.cantidadAgentes} agentes)');
        return equipo;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver este equipo');
      } else if (response.statusCode == 404) {
        throw Exception('Equipo no encontrado');
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Error al obtener equipo';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Error al obtener equipo #$equipoId: $e');
      rethrow;
    }
  }

  /// Obtiene los equipos de una campaña específica
  /// 
  /// [campanaId]: ID de la campaña
  /// 
  /// Returns: Lista de equipos asignados a la campaña
  static Future<List<EquipoModel>> listarEquiposPorCampana(int campanaId) async {
    try {
      final resultado = await listarEquipos(campana: campanaId);
      return resultado['equipos'] as List<EquipoModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar equipos de campaña $campanaId: $e');
      rethrow;
    }
  }

  /// Obtiene los equipos de un coordinador específico
  /// 
  /// [coordinadorId]: Documento del coordinador
  /// 
  /// Returns: Lista de equipos asignados al coordinador
  static Future<List<EquipoModel>> listarEquiposPorCoordinador(String coordinadorId) async {
    try {
      final resultado = await listarEquipos(coordinador: coordinadorId);
      return resultado['equipos'] as List<EquipoModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar equipos del coordinador $coordinadorId: $e');
      rethrow;
    }
  }

  /// Obtiene solo los equipos activos
  /// 
  /// Returns: Lista de equipos con estado activo
  static Future<List<EquipoModel>> listarEquiposActivos() async {
    try {
      final resultado = await listarEquipos(isActive: true);
      return resultado['equipos'] as List<EquipoModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar equipos activos: $e');
      rethrow;
    }
  }

  /// Obtiene los equipos inactivos
  /// 
  /// Returns: Lista de equipos con estado inactivo
  static Future<List<EquipoModel>> listarEquiposInactivos() async {
    try {
      final resultado = await listarEquipos(isActive: false);
      return resultado['equipos'] as List<EquipoModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar equipos inactivos: $e');
      rethrow;
    }
  }
}
