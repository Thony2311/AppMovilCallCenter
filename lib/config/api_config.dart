/// Configuración de la API del Call Center
/// Aquí se define la URL base del backend y todos los endpoints disponibles
class ApiConfig {
  // URL del nuevo backend (ngrok)
  static const String baseUrl = 'https://gwenn-infundibular-irreclaimably.ngrok-free.dev/api';
  
  // Timeouts para las peticiones
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints de autenticación (JWT)
  static const String loginEndpoint = '$baseUrl/auth/login/';
  static const String logoutEndpoint = '$baseUrl/auth/logout/';
  static const String refreshTokenEndpoint = '$baseUrl/auth/refresh/';
  
  // Endpoints de recuperación de contraseña
  static const String passwordResetRequestEndpoint = '$baseUrl/auth/password-reset/request/';
  static const String passwordResetValidateEndpoint = '$baseUrl/auth/password-reset/validate-token/';
  static const String passwordResetConfirmEndpoint = '$baseUrl/auth/password-reset/confirm/';

  // Endpoints de dashboard
  static const String dashboardStatsEndpoint = '$baseUrl/dashboard/stats';
  static const String dashboardSummaryEndpoint = '$baseUrl/dashboard/summary';

  // Endpoints de ventas
  static const String ventasEndpoint = '$baseUrl/ventas';
  static const String ventasByStatusEndpoint = '$baseUrl/ventas/status';
  static const String ventaDetailEndpoint = '$baseUrl/ventas'; // + /{id}
  static const String auditarVentaEndpoint = '$baseUrl/ventas'; // + /{id}/auditar
  
  // Endpoints de llamadas
  static const String llamadasEndpoint = '$baseUrl/llamadas';
  static const String llamadaDetailEndpoint = '$baseUrl/llamadas'; // + /{id}
  static const String reportarLlamadaEndpoint = '$baseUrl/llamadas'; // + /{id}/reportar

  // Endpoints de agentes
  static const String agentesEndpoint = '$baseUrl/agentes';
  static const String agenteKpiEndpoint = '$baseUrl/agentes'; // + /{id}/kpi

  // Endpoints de usuarios
  static const String usersEndpoint = '$baseUrl/users/';
  static const String userDetailEndpoint = '$baseUrl/users'; // + /{documento_id}/
  static const String userMeEndpoint = '$baseUrl/users/me/';
  static const String changePasswordEndpoint = '$baseUrl/users/change-password/';
  
  // Endpoints de estados de agente
  static const String estadoCurrentEndpoint = '$baseUrl/users/estados/current/';
  static const String estadosDisponiblesEndpoint = '$baseUrl/users/estados/disponibles/';
  static const String estadosTodosEndpoint = '$baseUrl/users/estados/todos/';
  
  // Endpoints de campañas
  static const String campanasEndpoint = '$baseUrl/campaigns/';
  static const String campanaDetailEndpoint = '$baseUrl/campaigns'; // + /{id}/
  
  // Endpoints de clientes
  static const String clientesEndpoint = '$baseUrl/campaigns/clientes/';
  static const String clienteDetailEndpoint = '$baseUrl/campaigns/clientes'; // + /{cliente_id}/
  
  // Endpoints de equipos
  static const String equiposEndpoint = '$baseUrl/campaigns/equipos/';
  static const String equipoDetailEndpoint = '$baseUrl/campaigns/equipos'; // + /{equipo_id}/
  
  // Endpoints de KPIs
  static const String kpiAgentesEndpoint = '$baseUrl/kpis/agentes/';
  static const String kpiAgenteDetalleEndpoint = '$baseUrl/kpis/agentes'; // + /{documento_id}/detalle/
  static const String kpiOverviewEndpoint = '$baseUrl/kpis/overview/';
  static const String kpiCoordinadorDetalleEndpoint = '$baseUrl/kpis/coordinador-detalle/';
  
  // Headers comunes
  static Map<String, String> headers({String? token}) {
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true', // 🔧 Evita la página de advertencia de ngrok
    };
    
    if (token != null && token.isNotEmpty) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }
    
    return defaultHeaders;
  }

  // Helper para construir URLs con parámetros
  static String buildUrl(String endpoint, {Map<String, dynamic>? queryParams}) {
    if (queryParams == null || queryParams.isEmpty) {
      return endpoint;
    }
    
    final uri = Uri.parse(endpoint);
    final newUri = uri.replace(queryParameters: queryParams.map(
      (key, value) => MapEntry(key, value.toString()),
    ));
    
    return newUri.toString();
  }
}
