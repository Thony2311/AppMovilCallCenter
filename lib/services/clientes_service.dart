import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/auth_manager.dart';
import '../models/clientes/cliente_model.dart';
import '../utils/app_logger.dart';

/// Servicio para gestionar operaciones relacionadas con clientes
/// 
/// Proporciona métodos para listar, obtener y buscar clientes
/// asignados a campañas del call center.
class ClientesService {
  /// Lista todos los clientes con filtros opcionales
  /// 
  /// [campana]: Filtrar por ID de campaña
  /// [search]: Buscar por nombre o teléfono
  /// [baseDatos]: Filtrar por ID de base de datos
  /// [page]: Número de página para paginación
  /// 
  /// Returns: Lista de clientes y total de resultados
  /// Throws: Exception si hay error en la petición
  static Future<Map<String, dynamic>> listarClientes({
    int? campana,
    String? search,
    int? baseDatos,
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
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (baseDatos != null) {
        queryParams['base_datos'] = baseDatos;
      }

      final url = ApiConfig.buildUrl(
        ApiConfig.clientesEndpoint,
        queryParams: queryParams,
      );

      AppLogger.info('👥 Obteniendo lista de clientes desde: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers(token: token),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final List<dynamic> results = (jsonData['results'] as List<dynamic>?) ?? [];
        final clientes = results
            .map((json) => ClienteModel.fromJson(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('✅ Se obtuvieron ${clientes.length} clientes exitosamente');

        return {
          'count': jsonData['count'] ?? 0,
          'next': jsonData['next'],
          'previous': jsonData['previous'],
          'clientes': clientes,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver los clientes');
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Error al obtener clientes';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Error al listar clientes: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles completos de un cliente específico
  /// 
  /// [clienteId]: ID del cliente a consultar
  /// 
  /// Returns: Modelo completo del cliente
  /// Throws: Exception si hay error en la petición o no se encuentra
  static Future<ClienteModel> obtenerCliente(int clienteId) async {
    try {
      final token = AuthManager().accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación disponible');
      }

      final url = '${ApiConfig.clienteDetailEndpoint}/$clienteId/';
      AppLogger.info('👥 Obteniendo cliente #$clienteId desde: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.headers(token: token),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final cliente = ClienteModel.fromJson(jsonData);
        
        AppLogger.info('✅ Cliente "${cliente.nombre}" obtenido exitosamente');
        return cliente;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver este cliente');
      } else if (response.statusCode == 404) {
        throw Exception('Cliente no encontrado');
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Error al obtener cliente';
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('❌ Error al obtener cliente #$clienteId: $e');
      rethrow;
    }
  }

  /// Obtiene los clientes de una campaña específica
  /// 
  /// [campanaId]: ID de la campaña
  /// [page]: Número de página para paginación
  /// 
  /// Returns: Lista de clientes de la campaña
  static Future<List<ClienteModel>> listarClientesPorCampana(
    int campanaId, {
    int page = 1,
  }) async {
    try {
      final resultado = await listarClientes(campana: campanaId, page: page);
      return resultado['clientes'] as List<ClienteModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar clientes de campaña $campanaId: $e');
      rethrow;
    }
  }

  /// Busca clientes por nombre o teléfono
  /// 
  /// [termino]: Término de búsqueda (nombre o teléfono)
  /// [campanaId]: Opcional - filtrar por campaña específica
  /// 
  /// Returns: Lista de clientes que coinciden con la búsqueda
  static Future<List<ClienteModel>> buscarClientes(
    String termino, {
    int? campanaId,
  }) async {
    try {
      if (termino.isEmpty) {
        return [];
      }

      final resultado = await listarClientes(
        search: termino,
        campana: campanaId,
      );
      return resultado['clientes'] as List<ClienteModel>;
    } catch (e) {
      AppLogger.error('❌ Error al buscar clientes con término "$termino": $e');
      rethrow;
    }
  }

  /// Obtiene clientes de una base de datos específica
  /// 
  /// [baseDatosId]: ID de la base de datos
  /// 
  /// Returns: Lista de clientes de la base de datos
  static Future<List<ClienteModel>> listarClientesPorBaseDatos(int baseDatosId) async {
    try {
      final resultado = await listarClientes(baseDatos: baseDatosId);
      return resultado['clientes'] as List<ClienteModel>;
    } catch (e) {
      AppLogger.error('❌ Error al listar clientes de base de datos $baseDatosId: $e');
      rethrow;
    }
  }
}
