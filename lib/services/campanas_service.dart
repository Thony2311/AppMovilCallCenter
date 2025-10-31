import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/auth_manager.dart';
import '../models/campanas/campana_model.dart';
import '../utils/app_logger.dart';

/// Servicio para gestionar operaciones relacionadas con campañas
/// 
/// Proporciona métodos para listar, obtener y filtrar campañas
/// del call center según los permisos del usuario autenticado.
class CampanasService {
  /// Lista todas las campañas con filtros opcionales
  /// 
  /// [estado]: Filtrar por estado (ACTIVA, PAUSADA, FINALIZADA)
  /// [jefeCampana]: Filtrar por documento del jefe de campaña
  /// [centro]: Filtrar por ID del centro
  /// [page]: Número de página para paginación
  /// 
  /// Returns: Lista de campañas y total de resultados
  /// Throws: Exception si hay error en la petición
  static Future<Map<String, dynamic>> listarCampanas({
    String? estado,
    String? jefeCampana,
    int? centro,
    int page = 1,
  }) async {
    try {
      final token = AuthManager().accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación disponible');
      }

      // Construir query parameters
      final Map<String, dynamic> queryParams = {'page': page};
      if (estado != null && estado.isNotEmpty) {
        queryParams['estado'] = estado;
      }
      if (jefeCampana != null && jefeCampana.isNotEmpty) {
        queryParams['jefe_campana'] = jefeCampana;
      }
      if (centro != null) {
        queryParams['centro'] = centro;
      }

      final url = ApiConfig.buildUrl(
        ApiConfig.campanasEndpoint,
        queryParams: queryParams,
      );

      AppLogger.info('📢 Obteniendo lista de campañas desde: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers(token: token),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final List<dynamic> results = (jsonData['results'] as List<dynamic>?) ?? [];
        final campanas = results
            .map((json) => CampanaModel.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('✅ Se obtuvieron ${campanas.length} campañas exitosamente');

        return {
          'count': jsonData['count'] ?? 0,
          'next': jsonData['next'],
          'previous': jsonData['previous'],
          'campanas': campanas,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver las campañas');
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Error al obtener campañas';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Error al listar campañas: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles completos de una campaña específica
  /// 
  /// [campanaId]: ID de la campaña a consultar
  /// 
  /// Returns: Modelo completo de la campaña
  /// Throws: Exception si hay error en la petición o no se encuentra
  static Future<CampanaModel> obtenerCampana(int campanaId) async {
    try {
      final token = AuthManager().accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación disponible');
      }

      final url = '${ApiConfig.campanaDetailEndpoint}/$campanaId/';
      AppLogger.info('📢 Obteniendo campaña #$campanaId desde: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers(token: token),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final campana = CampanaModel.fromJson(jsonData);
        
        AppLogger.info('✅ Campaña "${campana.nombre}" obtenida exitosamente');
        return campana;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver esta campaña');
      } else if (response.statusCode == 404) {
        throw Exception('Campaña no encontrada');
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Error al obtener campaña';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Error al obtener campaña #$campanaId: $e');
      rethrow;
    }
  }

  /// Obtiene solo las campañas activas
  /// 
  /// Returns: Lista de campañas con estado ACTIVA
  static Future<List<CampanaModel>> listarCampanasActivas() async {
    try {
      final resultado = await listarCampanas(estado: 'ACTIVA');
      return resultado['campanas'] as List<CampanaModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar campañas activas: $e');
      rethrow;
    }
  }

  /// Obtiene las campañas de un jefe de campaña específico
  /// 
  /// [jefeCampanaId]: Documento del jefe de campaña
  /// 
  /// Returns: Lista de campañas asignadas al jefe
  static Future<List<CampanaModel>> listarCampanasPorJefe(String jefeCampanaId) async {
    try {
      final resultado = await listarCampanas(jefeCampana: jefeCampanaId);
      return resultado['campanas'] as List<CampanaModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar campañas del jefe $jefeCampanaId: $e');
      rethrow;
    }
  }

  /// Obtiene las campañas de un centro específico
  /// 
  /// [centroId]: ID del centro
  /// 
  /// Returns: Lista de campañas del centro
  static Future<List<CampanaModel>> listarCampanasPorCentro(int centroId) async {
    try {
      final resultado = await listarCampanas(centro: centroId);
      return resultado['campanas'] as List<CampanaModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar campañas del centro $centroId: $e');
      rethrow;
    }
  }
}
