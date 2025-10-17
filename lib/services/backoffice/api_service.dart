import 'dart:async';
import 'dart:convert';
import '../../utils/app_logger.dart';
import 'package:http/http.dart' as http;
import '../../models/backoffice/venta_model.dart';
import '../../config/api_config.dart';

class ApiService {
  final String? _token;

  ApiService({String? token}) : _token = token;

  /// Obtiene todas las ventas desde la API
  Future<List<Venta>> fetchSales({String? status}) async {
    try {
      // Construir la URL con parámetros opcionales
      String url = ApiConfig.ventasEndpoint;
      if (status != null && status.isNotEmpty && status != "Todas") {
        url = ApiConfig.buildUrl(
          ApiConfig.ventasByStatusEndpoint,
          queryParams: {'status': _mapStatusToApi(status)},
        );
      }

      // Hacer la petición GET
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers(token: _token),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Normalizar a lista de items: la API puede devolver list, map con data o un solo objeto
        List<dynamic> rawList = [];
        if (jsonData is List) {
          rawList = jsonData;
        } else if (jsonData is Map<String, dynamic>) {
          final maybe = jsonData['data'] ?? jsonData['ventas'] ?? jsonData;
          if (maybe is List) {
            rawList = maybe;
          } else if (maybe is Map) {
            rawList = [maybe];
          }
        } else {
          AppLogger.warn('Formato inesperado en fetchSales: ${jsonData.runtimeType}',
              name: 'ApiService.fetchSales');
          return [];
        }

        final ventas = <Venta>[];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            try {
              ventas.add(Venta.fromJson(item));
            } catch (e) {
              AppLogger.warn('Error parseando venta item: $e', name: 'ApiService.fetchSales');
            }
          } else {
            AppLogger.warn('Venta item no es Map, se omite: ${item.runtimeType}',
                name: 'ApiService.fetchSales');
          }
        }

        return ventas;
      } else {
    AppLogger.warn('Error obteniendo ventas: ${response.statusCode}',
      name: 'ApiService.fetchSales');
        return [];
      }
    } on TimeoutException catch (e) {
    AppLogger.warn('Timeout obteniendo ventas: $e',
      name: 'ApiService.fetchSales');
      return [];
    } catch (e) {
    AppLogger.error('Error de conexión obteniendo ventas: $e',
      name: 'ApiService.fetchSales');
      return [];
    }
  }

  /// Obtiene el detalle de una venta específica
  Future<Venta?> fetchVentaDetail(int ventaId) async {
    try {
      final url = '${ApiConfig.ventaDetailEndpoint}/$ventaId';
      
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers(token: _token),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final ventaJson = jsonData['data'] ?? jsonData['venta'] ?? jsonData;
        if (ventaJson is Map<String, dynamic>) {
          return Venta.fromJson(ventaJson);
        } else {
          AppLogger.warn('Detalle de venta en formato inesperado: ${ventaJson.runtimeType}',
              name: 'ApiService.fetchVentaDetail');
          return null;
        }
      } else {
    AppLogger.warn('Error obteniendo detalle de venta: ${response.statusCode}',
      name: 'ApiService.fetchVentaDetail');
        return null;
      }
    } catch (e) {
    AppLogger.error('Error obteniendo detalle de venta: $e',
      name: 'ApiService.fetchVentaDetail');
      return null;
    }
  }

  /// Audita una venta (marca como auditada)
  Future<bool> auditarVenta(int ventaId, {String? observaciones}) async {
    try {
      final url = '${ApiConfig.auditarVentaEndpoint}/$ventaId/auditar';
      
      final body = jsonEncode({
        'observaciones': observaciones,
        'auditada': true,
      });

      final response = await http
          .put(
            Uri.parse(url),
            headers: ApiConfig.headers(token: _token),
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
    AppLogger.error('Error auditando venta: $e',
      name: 'ApiService.auditarVenta');
      return false;
    }
  }

  /// Reporta una venta (marca como reportada)
  Future<bool> reportarVenta(int ventaId, String motivo) async {
    try {
      final url = '${ApiConfig.ventaDetailEndpoint}/$ventaId/reportar';
      
      final body = jsonEncode({
        'motivo': motivo,
        'reportada': true,
      });

      final response = await http
          .put(
            Uri.parse(url),
            headers: ApiConfig.headers(token: _token),
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
    AppLogger.error('Error reportando venta: $e',
      name: 'ApiService.reportarVenta');
      return false;
    }
  }

  /// Mapea los nombres de filtro de la UI a los valores de la API
  String _mapStatusToApi(String uiStatus) {
    switch (uiStatus) {
      case "Ventas auditadas":
        return "auditada";
      case "Ventas":
        return "pendiente";
      case "Llamadas reportadas":
        return "reportada";
      default:
        return uiStatus.toLowerCase();
    }
  }
}
