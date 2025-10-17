import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../utils/app_logger.dart';

/// Modelo para las estadísticas del dashboard
class DashboardStats {
  final int llamadasReportadas;
  final int ventasAuditadas;
  final int ventasPorAuditar;
  final int totalVentas;
  final double montoTotal;

  DashboardStats({
    required this.llamadasReportadas,
    required this.ventasAuditadas,
    required this.ventasPorAuditar,
    required this.totalVentas,
    required this.montoTotal,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      llamadasReportadas: _asInt(json['llamadas_reportadas'] ?? json['reportadas'] ?? json['llamadasReportadas'] ?? 0),
      ventasAuditadas: _asInt(json['ventas_auditadas'] ?? json['auditadas'] ?? json['ventasAuditadas'] ?? 0),
      ventasPorAuditar: _asInt(json['ventas_por_auditar'] ?? json['pendientes'] ?? json['ventasPorAuditar'] ?? 0),
      totalVentas: _asInt(json['total_ventas'] ?? json['total'] ?? json['totalVentas'] ?? 0),
      montoTotal: _parseDouble(json['monto_total'] ?? 
                              json['monto'] ?? 
                              json['montoTotal'] ?? 0),
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'llamadas_reportadas': llamadasReportadas,
      'ventas_auditadas': ventasAuditadas,
      'ventas_por_auditar': ventasPorAuditar,
      'total_ventas': totalVentas,
      'monto_total': montoTotal,
    };
  }
}

/// Service para obtener datos del dashboard
class DashboardService {
  final String? _token;

  DashboardService({String? token}) : _token = token;

  /// Obtiene las estadísticas para el dashboard
  Future<DashboardStats?> fetchDashboardStats() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.dashboardStatsEndpoint),
            headers: ApiConfig.headers(token: _token),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // La respuesta puede venir como Map o List; normalizar a Map
        dynamic statsJson;
        if (jsonData is Map<String, dynamic>) {
          statsJson = jsonData['data'] ?? jsonData['stats'] ?? jsonData;
        } else if (jsonData is List && jsonData.isNotEmpty) {
          statsJson = jsonData.first;
        } else {
          AppLogger.warn('Respuesta inesperada para dashboard stats: ${jsonData.runtimeType}',
              name: 'DashboardService.fetchStats');
          return null;
        }

        if (statsJson is Map<String, dynamic>) {
          return DashboardStats.fromJson(statsJson);
        } else {
          AppLogger.warn('Dashboard stats no es un Map: ${statsJson.runtimeType}',
              name: 'DashboardService.fetchStats');
          return null;
        }
      } else {
    AppLogger.warn('Error obteniendo stats del dashboard: ${response.statusCode}',
      name: 'DashboardService.fetchStats');
        return null;
      }
    } on TimeoutException catch (e) {
    AppLogger.warn('Timeout obteniendo stats del dashboard: $e',
      name: 'DashboardService.fetchStats');
      return null;
    } catch (e) {
    AppLogger.error('Error de conexión obteniendo stats del dashboard: $e',
      name: 'DashboardService.fetchStats');
      return null;
    }
  }

  /// Obtiene un resumen general del dashboard
  Future<Map<String, dynamic>?> fetchDashboardSummary() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.dashboardSummaryEndpoint),
            headers: ApiConfig.headers(token: _token),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map<String, dynamic>) {
          final summary = jsonData['data'] ?? jsonData;
          if (summary is Map<String, dynamic>) return summary;
          // si viene en otro formato, envolverlo
          return {'data': summary};
        }

        // si viene como lista o primitivo, envolver en un map bajo 'data'
        return {'data': jsonData};
      } else {
    AppLogger.warn('Error obteniendo resumen del dashboard: ${response.statusCode}',
      name: 'DashboardService.fetchResumen');
        return null;
      }
    } catch (e) {
    AppLogger.error('Error obteniendo resumen del dashboard: $e',
      name: 'DashboardService.fetchResumen');
      return null;
    }
  }
}
