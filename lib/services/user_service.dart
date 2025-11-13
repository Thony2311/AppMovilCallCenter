import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/auth_manager.dart';
import '../models/usuario_model.dart';
import '../models/estado_agente_actual_model.dart';
import '../models/change_password_request_model.dart';
import '../utils/app_logger.dart';

// Interfaz para testing
abstract class UserServiceInterface {
  Future<Map<String, dynamic>> listarUsuariosInstance({
    String? role,
    bool? isActive,
    String? search,
    int? page,
  });
  
  Future<UsuarioModel> obtenerUsuarioInstance(String documentoId);
  Future<UsuarioModel> actualizarUsuarioInstance({
    required String documentoId,
    String? firstName,
    String? lastName,
    String? phone,
    String? fotoPerfil,
  });
  Future<String> cambiarContrasenaInstance(ChangePasswordRequestModel request);
  Future<UsuarioModel> obtenerPerfilActualInstance();
  Future<EstadoAgenteActualModel> obtenerEstadoActualInstance({String? agenteId});
  Future<List<EstadoAgenteActualModel>> obtenerAgentesDisponiblesInstance();
  Future<List<EstadoAgenteActualModel>> obtenerTodosLosEstadosInstance();
}

class UserService implements UserServiceInterface {
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  
  factory UserService() => _instance;
  
  UserService._internal();

  // ========== MÉTODOS DE INSTANCIA (PARA TESTING) ==========
  // 🔥 Nombres DIFERENTES: agregamos "Instance" al final

  @override
  Future<Map<String, dynamic>> listarUsuariosInstance({
    String? role,
    bool? isActive,
    String? search,
    int? page,
  }) async {
    return await _listarUsuariosStatic(
      role: role,
      isActive: isActive,
      search: search,
      page: page,
    );
  }

  @override
  Future<UsuarioModel> obtenerUsuarioInstance(String documentoId) async {
    return await _obtenerUsuarioStatic(documentoId);
  }

  @override
  Future<UsuarioModel> actualizarUsuarioInstance({
    required String documentoId,
    String? firstName,
    String? lastName,
    String? phone,
    String? fotoPerfil,
  }) async {
    return await _actualizarUsuarioStatic(
      documentoId: documentoId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      fotoPerfil: fotoPerfil,
    );
  }

  @override
  Future<String> cambiarContrasenaInstance(ChangePasswordRequestModel request) async {
    return await _cambiarContrasenaStatic(request);
  }

  @override
  Future<UsuarioModel> obtenerPerfilActualInstance() async {
    return await _obtenerPerfilActualStatic();
  }

  @override
  Future<EstadoAgenteActualModel> obtenerEstadoActualInstance({String? agenteId}) async {
    return await _obtenerEstadoActualStatic(agenteId: agenteId);
  }

  @override
  Future<List<EstadoAgenteActualModel>> obtenerAgentesDisponiblesInstance() async {
    return await _obtenerAgentesDisponiblesStatic();
  }

  @override
  Future<List<EstadoAgenteActualModel>> obtenerTodosLosEstadosInstance() async {
    return await _obtenerTodosLosEstadosStatic();
  }

  // ========== MÉTODOS ESTÁTICOS ORIGINALES (NO SE TOCAN) ==========
  // 🔥 Nombres EXACTAMENTE IGUALES - CERO CAMBIOS EN BLoC

  static Future<Map<String, dynamic>> listarUsuarios({
    String? role,
    bool? isActive,
    String? search,
    int? page,
  }) async {
    return await _instance.listarUsuariosInstance(
      role: role,
      isActive: isActive,
      search: search,
      page: page,
    );
  }

  static Future<UsuarioModel> obtenerUsuario(String documentoId) async {
    return await _instance.obtenerUsuarioInstance(documentoId);
  }

  static Future<UsuarioModel> actualizarUsuario({
    required String documentoId,
    String? firstName,
    String? lastName,
    String? phone,
    String? fotoPerfil,
  }) async {
    return await _instance.actualizarUsuarioInstance(
      documentoId: documentoId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      fotoPerfil: fotoPerfil,
    );
  }

  static Future<String> cambiarContrasena(ChangePasswordRequestModel request) async {
    return await _instance.cambiarContrasenaInstance(request);
  }

  static Future<UsuarioModel> obtenerPerfilActual() async {
    return await _instance.obtenerPerfilActualInstance();
  }

  static Future<EstadoAgenteActualModel> obtenerEstadoActual({String? agenteId}) async {
    return await _instance.obtenerEstadoActualInstance(agenteId: agenteId);
  }

  static Future<List<EstadoAgenteActualModel>> obtenerAgentesDisponibles() async {
    return await _instance.obtenerAgentesDisponiblesInstance();
  }

  static Future<List<EstadoAgenteActualModel>> obtenerTodosLosEstados() async {
    return await _instance.obtenerTodosLosEstadosInstance();
  }

  // ========== IMPLEMENTACIONES PRIVADAS (LÓGICA ORIGINAL) ==========

  static Future<Map<String, dynamic>> _listarUsuariosStatic({
    String? role,
    bool? isActive,
    String? search,
    int? page,
  }) async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
    try {
      final headers = _buildHeaders();
      final queryParams = <String, String>{};

      if (role != null) queryParams['role'] = role;
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      if (search != null) queryParams['search'] = search;
      if (page != null) queryParams['page'] = page.toString();

      final url = ApiConfig.buildUrl(ApiConfig.usersEndpoint, queryParams: queryParams);
      
      AppLogger.info('🔍 Listando usuarios: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _logSuccess('✅ Usuarios obtenidos: ${data['count'] ?? 0}');
        
        // Parsear la lista de usuarios
        final results = (data['results'] as List?)?.map((json) {
          return UsuarioModel.fromJson(json as Map<String, dynamic>);
        }).toList() ?? [];

        return {
          'count': data['count'] ?? 0,
          'next': data['next'],
          'previous': data['previous'],
          'results': results,
        };
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al listar usuarios: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al listar usuarios');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al listar usuarios: $e');
      rethrow;
    }
  }

  static Future<UsuarioModel> _obtenerUsuarioStatic(String documentoId) async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
    try {
      final headers = _buildHeaders();
      final url = '${ApiConfig.userDetailEndpoint}/$documentoId/';
      
      AppLogger.info('🔍 Obteniendo usuario: $documentoId');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _logSuccess('✅ Usuario obtenido: ${data['full_name']}');
        return UsuarioModel.fromJson(data);
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al obtener usuario: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al obtener usuario');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener usuario: $e');
      rethrow;
    }
  }

  static Future<UsuarioModel> _actualizarUsuarioStatic({
    required String documentoId,
    String? firstName,
    String? lastName,
    String? phone,
    String? fotoPerfil,
  }) async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
    try {
      final headers = _buildHeaders();
      final url = '${ApiConfig.userDetailEndpoint}/$documentoId/';
      
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phone != null) body['phone'] = phone;
      if (fotoPerfil != null) body['foto_perfil'] = fotoPerfil;

      AppLogger.info('📝 Actualizando usuario: $documentoId');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _logSuccess('✅ Usuario actualizado: ${data['full_name']}');
        return UsuarioModel.fromJson(data);
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al actualizar usuario: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al actualizar usuario');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al actualizar usuario: $e');
      rethrow;
    }
  }

  static Future<String> _cambiarContrasenaStatic(ChangePasswordRequestModel request) async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
    try {
      final headers = _buildHeaders();
      
      AppLogger.info('🔑 Cambiando contraseña...');
      
      final response = await http.post(
        Uri.parse(ApiConfig.changePasswordEndpoint),
        headers: headers,
        body: json.encode(request.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final message = (data['message'] ?? 'Contraseña actualizada exitosamente').toString();
        _logSuccess('✅ $message');
        return message;
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al cambiar contraseña: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? error.toString());
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al cambiar contraseña: $e');
      rethrow;
    }
  }

  static Future<UsuarioModel> _obtenerPerfilActualStatic() async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
    try {
      final headers = _buildHeaders();
      
      AppLogger.info('👤 Obteniendo perfil actual...');
      AppLogger.info('📍 URL: ${ApiConfig.userMeEndpoint}');
      
      final response = await http.get(
        Uri.parse(ApiConfig.userMeEndpoint),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      AppLogger.info('📊 Status Code: ${response.statusCode}');
      AppLogger.info('📄 Content-Type: ${response.headers['content-type']}');
      
      if (response.statusCode == 200) {
        // Verificar si la respuesta es JSON
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          AppLogger.error('❌ Respuesta NO es JSON. Content-Type: $contentType');
          AppLogger.error('🔍 Primeros 200 caracteres de la respuesta: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
          throw Exception('El servidor devolvió HTML en lugar de JSON. Verifica la URL del endpoint.');
        }
        
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _logSuccess('✅ Perfil obtenido: ${data['full_name']}');
        return UsuarioModel.fromJson(data);
      } else {
        // Intentar decodificar el error
        try {
          final error = json.decode(utf8.decode(response.bodyBytes));
          AppLogger.error('❌ Error al obtener perfil: ${error['detail'] ?? error}');
          throw Exception(error['detail'] ?? 'Error al obtener perfil');
        } catch (e) {
          // Si no se puede decodificar, es HTML
          AppLogger.error('❌ Respuesta de error NO es JSON');
          AppLogger.error('🔍 Respuesta: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          throw Exception('Error ${response.statusCode}: El servidor devolvió HTML. Endpoint incorrecto o no disponible.');
        }
      }
    } on FormatException catch (e) {
      AppLogger.error('❌ Error de formato JSON: $e');
      AppLogger.error('💡 El servidor está devolviendo HTML en lugar de JSON');
      AppLogger.error('🔧 Verifica: 1) URL correcta, 2) Endpoint existe, 3) Backend funcionando');
      throw Exception('Error de formato: El servidor devolvió HTML en lugar de JSON. Verifica la configuración del backend.');
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener perfil: $e');
      rethrow;
    }
  }

  static Future<EstadoAgenteActualModel> _obtenerEstadoActualStatic({String? agenteId}) async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
    try {
      final headers = _buildHeaders();
      final queryParams = <String, String>{};
      
      if (agenteId != null) queryParams['agente_id'] = agenteId;
      
      final url = ApiConfig.buildUrl(ApiConfig.estadoCurrentEndpoint, queryParams: queryParams);
      
      AppLogger.info('🔍 Obteniendo estado actual${agenteId != null ? ' del agente $agenteId' : ''}...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _logSuccess('✅ Estado obtenido: ${data['estado_valor']}');
        return EstadoAgenteActualModel.fromJson(data);
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al obtener estado: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al obtener estado');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener estado: $e');
      rethrow;
    }
  }

  static Future<List<EstadoAgenteActualModel>> _obtenerAgentesDisponiblesStatic() async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
    try {
      final headers = _buildHeaders();
      
      AppLogger.info('🔍 Obteniendo agentes disponibles...');
      
      final response = await http.get(
        Uri.parse(ApiConfig.estadosDisponiblesEndpoint),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List;
        _logSuccess('✅ Agentes disponibles: ${data.length}');
        
        return data.map((json) => EstadoAgenteActualModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al obtener agentes disponibles: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al obtener agentes disponibles');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener agentes disponibles: $e');
      rethrow;
    }
  }

  static Future<List<EstadoAgenteActualModel>> _obtenerTodosLosEstadosStatic() async {
    // ✅ TODO EL CÓDIGO ORIGINAL SE MANTIENE IDÉNTICO
    try {
      final headers = _buildHeaders();
      
      AppLogger.info('🔍 Obteniendo todos los estados...');
      
      final response = await http.get(
        Uri.parse(ApiConfig.estadosTodosEndpoint),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List;
        _logSuccess('✅ Estados obtenidos: ${data.length}');
        
        return data.map((json) => EstadoAgenteActualModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        AppLogger.error('❌ Error al obtener estados: ${error['detail'] ?? error}');
        throw Exception(error['detail'] ?? 'Error al obtener estados');
      }
    } catch (e) {
      AppLogger.error('❌ Excepción al obtener estados: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS AUXILIARES ORIGINALES ==========

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
}