/// Configuración de la API del Call Center
/// Aquí se define la URL base de la EC2 y todos los endpoints disponibles
class ApiConfig {
  // 🔹 IMPORTANTE: Reemplazar con la URL real de tu EC2
  // Ejemplo: 'http://ec2-XX-XXX-XXX-XXX.compute-1.amazonaws.com:8000'
  static const String baseUrl = 'http://100.27.207.32:3500/api';
  
  // ⏱️ Timeouts para las peticiones
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 🔐 Endpoints de autenticación
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String logoutEndpoint = '$baseUrl/auth/logout';
  static const String validateTokenEndpoint = '$baseUrl/auth/validate';

  // 📊 Endpoints de dashboard
  static const String dashboardStatsEndpoint = '$baseUrl/dashboard/stats';
  static const String dashboardSummaryEndpoint = '$baseUrl/dashboard/summary';

  // 💰 Endpoints de ventas
  static const String ventasEndpoint = '$baseUrl/ventas';
  static const String ventasByStatusEndpoint = '$baseUrl/ventas/status';
  static const String ventaDetailEndpoint = '$baseUrl/ventas'; // + /{id}
  static const String auditarVentaEndpoint = '$baseUrl/ventas'; // + /{id}/auditar
  
  // 📞 Endpoints de llamadas
  static const String llamadasEndpoint = '$baseUrl/llamadas';
  static const String llamadaDetailEndpoint = '$baseUrl/llamadas'; // + /{id}
  static const String reportarLlamadaEndpoint = '$baseUrl/llamadas'; // + /{id}/reportar

  // 👤 Endpoints de agentes
  static const String agentesEndpoint = '$baseUrl/agentes';
  static const String agenteKpiEndpoint = '$baseUrl/agentes'; // + /{id}/kpi
  
  // ⚙️ Headers comunes
  static Map<String, String> headers({String? token}) {
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }
    
    return defaultHeaders;
  }

  // 🛠️ Helper para construir URLs con parámetros
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
