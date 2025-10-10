import 'dart:async';
import 'dart:convert';
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
        
        // La respuesta puede venir como array directo o envuelto en "data"
        final List<dynamic> ventasJson = jsonData is List 
            ? jsonData 
            : (jsonData['data'] ?? jsonData['ventas'] ?? []);

        return ventasJson
            .map((json) => Venta.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print('Error obteniendo ventas: ${response.statusCode}');
        return [];
      }
    } on TimeoutException catch (e) {
      print('Timeout obteniendo ventas: $e');
      return [];
    } catch (e) {
      print('Error de conexión obteniendo ventas: $e');
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
        return Venta.fromJson(ventaJson);
      } else {
        print('Error obteniendo detalle de venta: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error obteniendo detalle de venta: $e');
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
      print('Error auditando venta: $e');
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
      print('Error reportando venta: $e');
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
