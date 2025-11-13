import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/auth_manager.dart';
import '../models/equipos/equipo_model.dart';
import '../utils/app_logger.dart';

// Interfaz para testing
abstract class EquiposServiceInterface {
  Future<Map<String, dynamic>> listarEquiposInstance({
    int? campana,
    String? coordinador,
    bool? isActive,
    int page = 1,
  });
  
  Future<EquipoModel> obtenerEquipoInstance(int equipoId);
  Future<List<EquipoModel>> listarEquiposPorCampanaInstance(int campanaId);
  Future<List<EquipoModel>> listarEquiposPorCoordinadorInstance(String coordinadorId);
  Future<List<EquipoModel>> listarEquiposActivosInstance();
  Future<List<EquipoModel>> listarEquiposInactivosInstance();
}

class EquiposService implements EquiposServiceInterface {
  // Singleton pattern
  static final EquiposService _instance = EquiposService._internal();
  
  factory EquiposService() => _instance;
  
  EquiposService._internal();

  // ========== MÉTODOS DE INSTANCIA (PARA TESTING) ==========
  // 🔥 Nombres DIFERENTES: agregamos "Instance" al final

  @override
  Future<Map<String, dynamic>> listarEquiposInstance({
    int? campana,
    String? coordinador,
    bool? isActive,
    int page = 1,
  }) async {
    return await _listarEquiposStatic(
      campana: campana,
      coordinador: coordinador,
      isActive: isActive,
      page: page,
    );
  }

  @override
  Future<EquipoModel> obtenerEquipoInstance(int equipoId) async {
    return await _obtenerEquipoStatic(equipoId);
  }

  @override
  Future<List<EquipoModel>> listarEquiposPorCampanaInstance(int campanaId) async {
    try {
      final resultado = await listarEquiposInstance(campana: campanaId);
      return resultado['equipos'] as List<EquipoModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar equipos de campaña $campanaId: $e');
      rethrow;
    }
  }

  @override
  Future<List<EquipoModel>> listarEquiposPorCoordinadorInstance(String coordinadorId) async {
    try {
      final resultado = await listarEquiposInstance(coordinador: coordinadorId);
      return resultado['equipos'] as List<EquipoModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar equipos del coordinador $coordinadorId: $e');
      rethrow;
    }
  }

  @override
  Future<List<EquipoModel>> listarEquiposActivosInstance() async {
    try {
      final resultado = await listarEquiposInstance(isActive: true);
      return resultado['equipos'] as List<EquipoModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar equipos activos: $e');
      rethrow;
    }
  }

  @override
  Future<List<EquipoModel>> listarEquiposInactivosInstance() async {
    try {
      final resultado = await listarEquiposInstance(isActive: false);
      return resultado['equipos'] as List<EquipoModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar equipos inactivos: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS ESTÁTICOS ORIGINALES (NO SE TOCAN) ==========
  // 🔥 Nombres EXACTAMENTE IGUALES - CERO CAMBIOS EN BLoC

  static Future<Map<String, dynamic>> listarEquipos({
    int? campana,
    String? coordinador,
    bool? isActive,
    int page = 1,
  }) async {
    return await _instance.listarEquiposInstance(
      campana: campana,
      coordinador: coordinador,
      isActive: isActive,
      page: page,
    );
  }

  static Future<EquipoModel> obtenerEquipo(int equipoId) async {
    return await _instance.obtenerEquipoInstance(equipoId);
  }

  static Future<List<EquipoModel>> listarEquiposPorCampana(int campanaId) async {
    return await _instance.listarEquiposPorCampanaInstance(campanaId);
  }

  static Future<List<EquipoModel>> listarEquiposPorCoordinador(String coordinadorId) async {
    return await _instance.listarEquiposPorCoordinadorInstance(coordinadorId);
  }

  static Future<List<EquipoModel>> listarEquiposActivos() async {
    return await _instance.listarEquiposActivosInstance();
  }

  static Future<List<EquipoModel>> listarEquiposInactivos() async {
    return await _instance.listarEquiposInactivosInstance();
  }

  // ========== IMPLEMENTACIONES PRIVADAS (LÓGICA ORIGINAL) ==========

  static Future<Map<String, dynamic>> _listarEquiposStatic({
    int? campana,
    String? coordinador,
    bool? isActive,
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

  static Future<EquipoModel> _obtenerEquipoStatic(int equipoId) async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
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
}