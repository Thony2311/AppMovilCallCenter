import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../config/auth_manager.dart';
import '../../models/kpis/kpi_agente_list_model.dart';
import '../../models/kpis/kpi_agente_detalle_model.dart';
import '../../models/kpis/kpi_overview_model.dart';
import '../../models/kpis/kpi_agente_overview_model.dart';
import '../../models/kpis/kpi_agente_metricas_model.dart';
import '../../utils/app_logger.dart';

// Interfaz para testing
abstract class KPIsServiceInterface {
  Future<List<KPIAgenteListModel>> listarAgentesInstance({
    String? role,
    bool? isActive,
    String? search,
  });
  
  Future<KPIAgenteDetalleModel> obtenerKPIAgenteInstance({
    required String documentoId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? rango,
  });
  
  Future<KPIOverviewModel> obtenerOverviewInstance({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? campanaId,
    int? equipoId,
  });
  
  Future<KPIAgenteMetricasModel> obtenerMetricasAgenteNuevoInstance({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });
  
  Future<KPIAgenteOverviewModel> obtenerMetricasAgenteInstance({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });
  
  Future<Map<String, dynamic>> obtenerKPICoordinadorInstance({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? equipoId,
  });
}

class KPIsService implements KPIsServiceInterface {
  // Singleton pattern
  static final KPIsService _instance = KPIsService._internal();
  
  factory KPIsService() => _instance;
  
  KPIsService._internal();

  // ========== MÉTODOS DE INSTANCIA (PARA TESTING) ==========

  @override
  Future<List<KPIAgenteListModel>> listarAgentesInstance({
    String? role,
    bool? isActive,
    String? search,
  }) async {
    return await _listarAgentes(
      role: role,
      isActive: isActive,
      search: search,
    );
  }

  @override
  Future<KPIAgenteDetalleModel> obtenerKPIAgenteInstance({
    required String documentoId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? rango,
  }) async {
    return await _obtenerKPIAgente(
      documentoId: documentoId,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      rango: rango,
    );
  }

  @override
  Future<KPIOverviewModel> obtenerOverviewInstance({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? campanaId,
    int? equipoId,
  }) async {
    return await _obtenerOverview(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      campanaId: campanaId,
      equipoId: equipoId,
    );
  }

  @override
  Future<KPIAgenteMetricasModel> obtenerMetricasAgenteNuevoInstance({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    return await _obtenerMetricasAgenteNuevo(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );
  }

  @override
  Future<KPIAgenteOverviewModel> obtenerMetricasAgenteInstance({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    return await _obtenerMetricasAgente(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );
  }

  @override
  Future<Map<String, dynamic>> obtenerKPICoordinadorInstance({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? equipoId,
  }) async {
    return await _obtenerKPICoordinador(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      equipoId: equipoId,
    );
  }

  // ========== MÉTODOS ESTÁTICOS ORIGINALES (NO SE TOCAN) ==========

  static Future<List<KPIAgenteListModel>> listarAgentes({
    String? role,
    bool? isActive,
    String? search,
  }) async {
    return await _instance.listarAgentesInstance(
      role: role,
      isActive: isActive,
      search: search,
    );
  }

  static Future<KPIAgenteDetalleModel> obtenerKPIAgente({
    required String documentoId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? rango,
  }) async {
    return await _instance.obtenerKPIAgenteInstance(
      documentoId: documentoId,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      rango: rango,
    );
  }

  static Future<KPIOverviewModel> obtenerOverview({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? campanaId,
    int? equipoId,
  }) async {
    return await _instance.obtenerOverviewInstance(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      campanaId: campanaId,
      equipoId: equipoId,
    );
  }

  static Future<KPIAgenteMetricasModel> obtenerMetricasAgenteNuevo({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    return await _instance.obtenerMetricasAgenteNuevoInstance(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );
  }

  static Future<KPIAgenteOverviewModel> obtenerMetricasAgente({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    return await _instance.obtenerMetricasAgenteInstance(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );
  }

  static Future<Map<String, dynamic>> obtenerKPICoordinador({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? equipoId,
  }) async {
    return await _instance.obtenerKPICoordinadorInstance(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      equipoId: equipoId,
    );
  }

  // ========== IMPLEMENTACIONES PRIVADAS (LÓGICA ORIGINAL) ==========

  static Future<List<KPIAgenteListModel>> _listarAgentes({
    String? role,
    bool? isActive,
    String? search,
  }) async {
    try {
      final headers = _buildHeaders();
      final queryParams = <String, String>{};

      if (role != null) queryParams['role'] = role;
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      if (search != null) queryParams['search'] = search;

      final url = ApiConfig.buildUrl(ApiConfig.kpiAgentesEndpoint, queryParams: queryParams);
      
      AppLogger.info('🔍 Listando agentes KPI: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List;
        _logSuccess('✅ Agentes KPI obtenidos: ${data.length}');
        
        return data.map((json) => KPIAgenteListModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al listar agentes KPI: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al listar agentes KPI');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al listar agentes KPI: $e');
      rethrow;
    }
  }

  static Future<KPIAgenteDetalleModel> _obtenerKPIAgente({
    required String documentoId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? rango,
  }) async {
    try {
      final headers = _buildHeaders();
      final queryParams = <String, String>{};

      if (fechaDesde != null) {
        queryParams['fecha_desde'] = fechaDesde.toIso8601String().split('T')[0];
      }
      if (fechaHasta != null) {
        queryParams['fecha_hasta'] = fechaHasta.toIso8601String().split('T')[0];
      }
      if (rango != null) queryParams['rango'] = rango;

      final endpoint = '${ApiConfig.kpiAgenteDetalleEndpoint}/$documentoId/detalle/';
      final url = ApiConfig.buildUrl(endpoint, queryParams: queryParams);
      
      AppLogger.info('🔍 Obteniendo KPI del agente $documentoId: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _logSuccess('✅ KPI agente obtenido: ${data['agente_nombre']}');
        
        return KPIAgenteDetalleModel.fromJson(data);
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al obtener KPI agente: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al obtener KPI del agente');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener KPI agente: $e');
      rethrow;
    }
  }

  static Future<KPIOverviewModel> _obtenerOverview({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? campanaId,
    int? equipoId,
  }) async {
    try {
      final headers = _buildHeaders();
      
      final ahora = DateTime.now();
      final desde = fechaDesde ?? ahora;
      final hasta = fechaHasta ?? ahora;
      
      final queryParams = <String, String>{
        'from': desde.toIso8601String().split('T')[0],
        'to': hasta.toIso8601String().split('T')[0],
      };

      if (campanaId != null) queryParams['campana'] = campanaId.toString();
      if (equipoId != null) queryParams['equipo'] = equipoId.toString();

      final url = ApiConfig.buildUrl(ApiConfig.kpiOverviewEndpoint, queryParams: queryParams);
      
      AppLogger.info('🔍 Obteniendo overview de KPIs: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        
        AppLogger.info('📦 Respuesta del backend:');
        AppLogger.info('   - tipo_usuario: ${data['tipo_usuario']}');
        AppLogger.info('   - fecha_desde: ${data['fecha_desde']}');
        AppLogger.info('   - fecha_hasta: ${data['fecha_hasta']}');
        AppLogger.info('   - totales: ${data['totales']}');
        
        _logSuccess('✅ Overview KPI obtenido: ${data['tipo_usuario']}');
        
        try {
          return KPIOverviewModel.fromJson(data);
        } catch (e, stackTrace) {
          AppLogger.error('❌ Error al parsear respuesta del backend: $e');
          AppLogger.error('Datos recibidos: $data');
          AppLogger.error('StackTrace: $stackTrace');
          rethrow;
        }
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al obtener overview KPI: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al obtener overview de KPIs');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener overview KPI: $e');
      rethrow;
    }
  }

  static Future<KPIAgenteMetricasModel> _obtenerMetricasAgenteNuevo({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final headers = _buildHeaders();
      
      final ahora = DateTime.now();
      final desde = fechaDesde ?? ahora;
      final hasta = fechaHasta ?? ahora;
      
      final queryParams = <String, String>{
        'from': desde.toIso8601String().split('T')[0],
        'to': hasta.toIso8601String().split('T')[0],
      };

      final url = ApiConfig.buildUrl(ApiConfig.kpiOverviewEndpoint, queryParams: queryParams);
      
      AppLogger.info('📊 Obteniendo métricas del agente (nuevo formato): $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      AppLogger.info('📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          AppLogger.error('❌ Respuesta NO es JSON. Content-Type: $contentType');
          throw Exception('El servidor devolvió HTML en lugar de JSON.');
        }

        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        
        AppLogger.info('📦 Estructura de respuesta recibida:');
        AppLogger.info('   - Keys: ${data.keys.toList()}');
        AppLogger.info('   - values.llamadas_atendidas: ${data['values']?['llamadas_atendidas']}');
        AppLogger.info('   - series.llamadas_por_hora: ${(data['series']?['llamadas_por_hora'] as List?)?.length ?? 0} items');
        
        _logSuccess('✅ Métricas del agente obtenidas');
        
        return KPIAgenteMetricasModel.fromJson(data);
      } else {
        try {
          final error = json.decode(utf8.decode(response.bodyBytes));
          AppLogger.error('❌ Error al obtener métricas: ${error['detail'] ?? error}');
          throw Exception(error['detail'] ?? 'Error al obtener métricas del agente');
        } catch (e) {
          AppLogger.error('❌ Respuesta de error NO es JSON');
          throw Exception('Error ${response.statusCode}: El servidor devolvió HTML.');
        }
      }
    } on FormatException catch (e) {
      AppLogger.error('❌ Error de formato JSON: $e');
      throw Exception('Error de formato: El servidor devolvió HTML en lugar de JSON.');
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener métricas del agente: $e');
      rethrow;
    }
  }

  static Future<KPIAgenteOverviewModel> _obtenerMetricasAgente({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final headers = _buildHeaders();
      
      final ahora = DateTime.now();
      final desde = fechaDesde ?? ahora;
      final hasta = fechaHasta ?? ahora;
      
      final queryParams = <String, String>{
        'from': desde.toIso8601String().split('T')[0],
        'to': hasta.toIso8601String().split('T')[0],
      };

      final url = ApiConfig.buildUrl(ApiConfig.kpiOverviewEndpoint, queryParams: queryParams);
      
      AppLogger.info('📊 Obteniendo métricas del agente: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      AppLogger.info('📊 Status Code: ${response.statusCode}');
      AppLogger.info('📄 Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          AppLogger.error('❌ Respuesta NO es JSON. Content-Type: $contentType');
          throw Exception('El servidor devolvió HTML en lugar de JSON.');
        }

        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _logSuccess('✅ Métricas del agente obtenidas: ${data['total_llamadas']} llamadas');
        
        return KPIAgenteOverviewModel.fromJson(data);
      } else {
        try {
          final error = json.decode(utf8.decode(response.bodyBytes));
          AppLogger.error('❌ Error al obtener métricas: ${error['detail'] ?? error}');
          throw Exception(error['detail'] ?? 'Error al obtener métricas del agente');
        } catch (e) {
          AppLogger.error('❌ Respuesta de error NO es JSON');
          throw Exception('Error ${response.statusCode}: El servidor devolvió HTML.');
        }
      }
    } on FormatException catch (e) {
      AppLogger.error('❌ Error de formato JSON: $e');
      throw Exception('Error de formato: El servidor devolvió HTML en lugar de JSON.');
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener métricas del agente: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _obtenerKPICoordinador({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? equipoId,
  }) async {
    try {
      final headers = _buildHeaders();
      final queryParams = <String, String>{};

      if (fechaDesde != null) {
        queryParams['fecha_desde'] = fechaDesde.toIso8601String().split('T')[0];
      }
      if (fechaHasta != null) {
        queryParams['fecha_hasta'] = fechaHasta.toIso8601String().split('T')[0];
      }
      if (equipoId != null) queryParams['equipo_id'] = equipoId.toString();

      final url = ApiConfig.buildUrl(ApiConfig.kpiCoordinadorDetalleEndpoint, queryParams: queryParams);
      
      AppLogger.info('🔍 Obteniendo KPI detallado coordinador: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _logSuccess('✅ KPI coordinador obtenido: ${data['coordinador_nombre']}');
        
        return data;
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al obtener KPI coordinador: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al obtener KPIs del coordinador');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener KPI coordinador: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS AUXILIARES ORIGINALES ==========

  static String? _getToken() {
    return AuthManager().accessToken;
  }

  static Map<String, String> _buildHeaders() {
    final token = _getToken();
    return ApiConfig.headers(token: token);
  }

  static void _logSuccess(String message) {
    AppLogger.info(message);
  }
}