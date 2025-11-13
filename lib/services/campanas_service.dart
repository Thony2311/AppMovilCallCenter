import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/auth_manager.dart';
import '../models/campanas/campana_model.dart';
import '../utils/app_logger.dart';

// Interfaz para testing
abstract class CampanasServiceInterface {
  Future<Map<String, dynamic>> listarCampanasInstance({
    String? estado,
    String? jefeCampana,
    int? centro,
    int page = 1,
  });
  
  Future<CampanaModel> obtenerCampanaInstance(int campanaId);
  Future<List<CampanaModel>> listarCampanasActivasInstance();
  Future<List<CampanaModel>> listarCampanasPorJefeInstance(String jefeCampanaId);
  Future<List<CampanaModel>> listarCampanasPorCentroInstance(int centroId);
}

class CampanasService implements CampanasServiceInterface {
  // Singleton pattern
  static final CampanasService _instance = CampanasService._internal();
  
  factory CampanasService() => _instance;
  
  CampanasService._internal();

  // ========== MÉTODOS DE INSTANCIA (PARA TESTING) ==========

  @override
  Future<Map<String, dynamic>> listarCampanasInstance({
    String? estado,
    String? jefeCampana,
    int? centro,
    int page = 1,
  }) async {
    return await _listarCampanasStatic(
      estado: estado,
      jefeCampana: jefeCampana,
      centro: centro,
      page: page,
    );
  }

  @override
  Future<CampanaModel> obtenerCampanaInstance(int campanaId) async {
    return await _obtenerCampanaStatic(campanaId);
  }

  @override
  Future<List<CampanaModel>> listarCampanasActivasInstance() async {
    try {
      final resultado = await listarCampanasInstance(estado: 'ACTIVA');
      return resultado['campanas'] as List<CampanaModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar campañas activas: $e');
      rethrow;
    }
  }

  @override
  Future<List<CampanaModel>> listarCampanasPorJefeInstance(String jefeCampanaId) async {
    try {
      final resultado = await listarCampanasInstance(jefeCampana: jefeCampanaId);
      return resultado['campanas'] as List<CampanaModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar campañas del jefe $jefeCampanaId: $e');
      rethrow;
    }
  }

  @override
  Future<List<CampanaModel>> listarCampanasPorCentroInstance(int centroId) async {
    try {
      final resultado = await listarCampanasInstance(centro: centroId);
      return resultado['campanas'] as List<CampanaModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar campañas del centro $centroId: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS ESTÁTICOS ORIGINALES (NO SE TOCAN) ==========

  static Future<Map<String, dynamic>> listarCampanas({
    String? estado,
    String? jefeCampana,
    int? centro,
    int page = 1,
  }) async {
    return await _instance.listarCampanasInstance(
      estado: estado,
      jefeCampana: jefeCampana,
      centro: centro,
      page: page,
    );
  }

  static Future<CampanaModel> obtenerCampana(int campanaId) async {
    return await _instance.obtenerCampanaInstance(campanaId);
  }

  static Future<List<CampanaModel>> listarCampanasActivas() async {
    return await _instance.listarCampanasActivasInstance();
  }

  static Future<List<CampanaModel>> listarCampanasPorJefe(String jefeCampanaId) async {
    return await _instance.listarCampanasPorJefeInstance(jefeCampanaId);
  }

  static Future<List<CampanaModel>> listarCampanasPorCentro(int centroId) async {
    return await _instance.listarCampanasPorCentroInstance(centroId);
  }

  // ========== IMPLEMENTACIONES PRIVADAS (LÓGICA ORIGINAL) ==========

  static Future<Map<String, dynamic>> _listarCampanasStatic({
    String? estado,
    String? jefeCampana,
    int? centro,
    int page = 1,
  }) async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
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

  static Future<CampanaModel> _obtenerCampanaStatic(int campanaId) async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
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
}