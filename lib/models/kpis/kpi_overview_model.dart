import 'equipo_kpi_model.dart';
import 'campana_kpi_model.dart';
import 'centro_kpi_model.dart';
import 'llamada_por_hora_model.dart';
import 'top_agente_model.dart';

/// Modelo para la vista general de KPIs
/// Estructura adaptable según el rol del usuario
class KPIOverviewModel {
  final String tipoUsuario;
  final DateTime fechaDesde;
  final DateTime fechaHasta;
  
  // Datos específicos según rol
  final List<EquipoKPIModel>? equipos; // Para COORDINADOR
  final List<CampanaKPIModel>? campanas; // Para JEFE_CAMPANA
  final List<CentroKPIModel>? centros; // Para ADMIN/BACKOFFICE
  
  // Totales generales
  final Map<String, dynamic> totales;
  
  // Datos adicionales opcionales
  final List<LlamadaPorHoraModel>? llamadasPorHora;
  final List<TopAgenteModel>? topAgentes;

  KPIOverviewModel({
    required this.tipoUsuario,
    required this.fechaDesde,
    required this.fechaHasta,
    this.equipos,
    this.campanas,
    this.centros,
    required this.totales,
    this.llamadasPorHora,
    this.topAgentes,
  });

  factory KPIOverviewModel.fromJson(Map<String, dynamic> json) {
    // Parsear fechas de forma segura
    DateTime parseFecha(dynamic fecha, DateTime fallback) {
      if (fecha == null) return fallback;
      try {
        return DateTime.parse(fecha.toString());
      } catch (e) {
        return fallback;
      }
    }
    
    final ahora = DateTime.now();
    
    return KPIOverviewModel(
      tipoUsuario: json['tipo_usuario']?.toString() ?? '',
      fechaDesde: parseFecha(json['fecha_desde'], ahora),
      fechaHasta: parseFecha(json['fecha_hasta'], ahora),
      equipos: (json['equipos'] as List<dynamic>?)
          ?.map((e) => EquipoKPIModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      campanas: (json['campanas'] as List<dynamic>?)
          ?.map((c) => CampanaKPIModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      centros: (json['centros'] as List<dynamic>?)
          ?.map((c) => CentroKPIModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      totales: json['totales'] as Map<String, dynamic>? ?? 
               json['totales_sistema'] as Map<String, dynamic>? ?? 
               {},
      llamadasPorHora: (json['llamadas_por_hora'] as List<dynamic>? ?? json['series'] as List<dynamic>?)
          ?.map((l) => LlamadaPorHoraModel.fromJson(l as Map<String, dynamic>))
          .toList(),
      topAgentes: (json['top_agentes'] as List<dynamic>?)
          ?.map((t) => TopAgenteModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_usuario': tipoUsuario,
      'fecha_desde': fechaDesde.toIso8601String(),
      'fecha_hasta': fechaHasta.toIso8601String(),
      'equipos': equipos?.map((e) => e.toJson()).toList(),
      'campanas': campanas?.map((c) => c.toJson()).toList(),
      'centros': centros?.map((c) => c.toJson()).toList(),
      'totales': totales,
      'llamadas_por_hora': llamadasPorHora?.map((l) => l.toJson()).toList(),
      'top_agentes': topAgentes?.map((t) => t.toJson()).toList(),
    };
  }

  /// Verifica si es vista de coordinador
  bool get isCoordinador => tipoUsuario.toUpperCase() == 'COORDINADOR';

  /// Verifica si es vista de jefe de campaña
  bool get isJefeCampana => tipoUsuario.toUpperCase() == 'JEFE_CAMPANA';

  /// Verifica si es vista de admin
  bool get isAdmin => tipoUsuario.toUpperCase() == 'ADMIN' || tipoUsuario.toUpperCase() == 'BACKOFFICE';

  /// Obtiene el total de llamadas de los totales
  int get totalLlamadas => (totales['total_llamadas'] as num?)?.toInt() ?? 0;

  /// Obtiene el total de ventas de los totales
  int get totalVentas => (totales['ventas_realizadas'] as num?)?.toInt() ?? 0;

  /// Obtiene la tasa de conversión de los totales
  double get tasaConversion => (totales['tasa_conversion'] as num?)?.toDouble() ?? 0.0;
}
