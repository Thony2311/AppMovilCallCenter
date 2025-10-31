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

/// Servicio para gestión de KPIs del Call Center
/// 
/// Este servicio maneja todas las operaciones de consulta de métricas
/// y estadísticas de agentes, equipos, campañas y centros.
class KPIsService {
  /// Obtiene el token de autenticación actual
  static String? _getToken() {
    return AuthManager().accessToken;
  }

  /// Construye headers con autenticación
  static Map<String, String> _buildHeaders() {
    final token = _getToken();
    return ApiConfig.headers(token: token);
  }

  /// Helper para loggear éxito
  static void _logSuccess(String message) {
    AppLogger.info(message);
  }

  // ==================== ENDPOINTS DE KPIS ====================

  /// 1. Listar Agentes (Vista KPI)
  /// GET /api/kpis/agentes/
  /// 
  /// Query Parameters opcionales:
  /// - role: Filtrar por rol
  /// - is_active: Filtrar activos/inactivos
  /// - search: Buscar por nombre o email
  static Future<List<KPIAgenteListModel>> listarAgentes({
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

  /// 2. KPI Detallado de Agente
  /// GET /api/kpis/agentes/{documento_id}/detalle/
  /// 
  /// Query Parameters opcionales:
  /// - fecha_desde: YYYY-MM-DD (default: hoy)
  /// - fecha_hasta: YYYY-MM-DD (default: hoy)
  /// - rango: hoy | semana | mes | personalizado (default: hoy)
  static Future<KPIAgenteDetalleModel> obtenerKPIAgente({
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

  /// 3. Overview de KPIs (Vista General)
  /// GET /api/kpis/overview/
  /// 
  /// Query Parameters:
  /// - from: YYYY-MM-DD (fecha desde)
  /// - to: YYYY-MM-DD (fecha hasta)
  /// - campana: ID de campaña (para filtrar)
  /// - equipo: ID de equipo (para filtrar)
  static Future<KPIOverviewModel> obtenerOverview({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? campanaId,
    int? equipoId,
  }) async {
    try {
      final headers = _buildHeaders();
      
      // Si no se proporcionan fechas, usar la fecha de hoy
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
        
        // Log detallado de la respuesta
        AppLogger.info('📦 Respuesta del backend:');
        AppLogger.info('   - tipo_usuario: ${data['tipo_usuario']}');
        AppLogger.info('   - fecha_desde: ${data['fecha_desde']}');
        AppLogger.info('   - fecha_hasta: ${data['fecha_hasta']}');
        AppLogger.info('   - totales: ${data['totales']}');
        AppLogger.info('   - Buscando series de llamadas...');
        AppLogger.info('   - llamadas_por_hora: ${data['llamadas_por_hora']?.runtimeType} (${(data['llamadas_por_hora'] as List?)?.length ?? 0} items)');
        AppLogger.info('   - series: ${data['series']?.runtimeType} (${(data['series'] as List?)?.length ?? 0} items)');
        AppLogger.info('   - Keys disponibles: ${data.keys.toList()}');
        
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

  /// 3b. KPIs del Agente desde Overview (Nuevo formato con values, meta, series)
  /// GET /api/kpis/overview/
  /// Para AGENTE - El backend devuelve métricas con estructura: values, meta, series
  /// 
  /// Query Parameters requeridos:
  /// - from: YYYY-MM-DD (fecha desde)
  /// - to: YYYY-MM-DD (fecha hasta)
  static Future<KPIAgenteMetricasModel> obtenerMetricasAgenteNuevo({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final headers = _buildHeaders();
      
      // Si no se proporcionan fechas, usar la fecha de hoy
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
        // Verificar que sea JSON
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

  /// 3c. KPIs del Agente desde Overview (Formato antiguo - deprecated)
  /// GET /api/kpis/overview/
  /// Para AGENTE - El backend devuelve solo las métricas propias del agente
  /// 
  /// Query Parameters requeridos:
  /// - from: YYYY-MM-DD (fecha desde)
  /// - to: YYYY-MM-DD (fecha hasta)
  static Future<KPIAgenteOverviewModel> obtenerMetricasAgente({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final headers = _buildHeaders();
      
      // Si no se proporcionan fechas, usar la fecha de hoy
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
        // Verificar que sea JSON
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

  /// 4. KPIs de Coordinador (Detallado)
  /// GET /api/kpis/coordinador-detalle/
  /// Solo para COORDINADOR
  /// 
  /// Query Parameters opcionales:
  /// - fecha_desde: YYYY-MM-DD
  /// - fecha_hasta: YYYY-MM-DD
  /// - equipo_id: ID específico de equipo
  static Future<Map<String, dynamic>> obtenerKPICoordinador({
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
}
