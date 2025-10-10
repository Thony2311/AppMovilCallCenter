import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

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
      llamadasReportadas: json['llamadas_reportadas'] ?? 
                         json['reportadas'] ?? 
                         json['llamadasReportadas'] ?? 0,
      ventasAuditadas: json['ventas_auditadas'] ?? 
                      json['auditadas'] ?? 
                      json['ventasAuditadas'] ?? 0,
      ventasPorAuditar: json['ventas_por_auditar'] ?? 
                       json['pendientes'] ?? 
                       json['ventasPorAuditar'] ?? 0,
      totalVentas: json['total_ventas'] ?? 
                  json['total'] ?? 
                  json['totalVentas'] ?? 0,
      montoTotal: _parseDouble(json['monto_total'] ?? 
                              json['monto'] ?? 
                              json['montoTotal'] ?? 0),
    );
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
        
        // La respuesta puede venir directa o envuelta en "data"
        final statsJson = jsonData['data'] ?? jsonData['stats'] ?? jsonData;
        
        return DashboardStats.fromJson(statsJson);
      } else {
        print('Error obteniendo stats del dashboard: ${response.statusCode}');
        return null;
      }
    } on TimeoutException catch (e) {
      print('Timeout obteniendo stats del dashboard: $e');
      return null;
    } catch (e) {
      print('Error de conexión obteniendo stats del dashboard: $e');
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
        return jsonData['data'] ?? jsonData;
      } else {
        print('Error obteniendo resumen del dashboard: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error obteniendo resumen del dashboard: $e');
      return null;
    }
  }
}
