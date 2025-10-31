/// Modelo para las métricas del agente desde el endpoint overview
/// Estructura específica para la respuesta del backend con values, meta y series
class KPIAgenteMetricasModel {
  final DateTime now;
  final ValoresMetricas values;
  final MetasMetricas meta;
  final SeriesMetricas series;

  KPIAgenteMetricasModel({
    required this.now,
    required this.values,
    required this.meta,
    required this.series,
  });

  factory KPIAgenteMetricasModel.fromJson(Map<String, dynamic> json) {
    // Parsear fecha de forma segura
    DateTime parseNow() {
      try {
        return DateTime.parse(json['now'].toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return KPIAgenteMetricasModel(
      now: parseNow(),
      values: ValoresMetricas.fromJson(json['values'] as Map<String, dynamic>? ?? {}),
      meta: MetasMetricas.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
      series: SeriesMetricas.fromJson(json['series'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'now': now.toIso8601String(),
      'values': values.toJson(),
      'meta': meta.toJson(),
      'series': series.toJson(),
    };
  }
}

/// Valores actuales de las métricas
class ValoresMetricas {
  final int llamadasAtendidas;
  final int ventasRealizadas;
  final int tiempoPromedioLlamada;
  final double llamadasPorHora;
  final int cumplimiento;

  ValoresMetricas({
    required this.llamadasAtendidas,
    required this.ventasRealizadas,
    required this.tiempoPromedioLlamada,
    required this.llamadasPorHora,
    required this.cumplimiento,
  });

  factory ValoresMetricas.fromJson(Map<String, dynamic> json) {
    return ValoresMetricas(
      llamadasAtendidas: (json['llamadas_atendidas'] as num?)?.toInt() ?? 0,
      ventasRealizadas: (json['ventas_realizadas'] as num?)?.toInt() ?? 0,
      tiempoPromedioLlamada: (json['tiempo_promedio_llamada'] as num?)?.toInt() ?? 0,
      llamadasPorHora: (json['llamadas_por_hora'] as num?)?.toDouble() ?? 0.0,
      cumplimiento: (json['cumplimiento'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'llamadas_atendidas': llamadasAtendidas,
      'ventas_realizadas': ventasRealizadas,
      'tiempo_promedio_llamada': tiempoPromedioLlamada,
      'llamadas_por_hora': llamadasPorHora,
      'cumplimiento': cumplimiento,
    };
  }
}

/// Metas de las métricas
class MetasMetricas {
  final int llamadasAtendidas;
  final int ventasRealizadas;
  final int tiempoPromedioLlamada;
  final int llamadasPorHora;
  final int cumplimiento;

  MetasMetricas({
    required this.llamadasAtendidas,
    required this.ventasRealizadas,
    required this.tiempoPromedioLlamada,
    required this.llamadasPorHora,
    required this.cumplimiento,
  });

  factory MetasMetricas.fromJson(Map<String, dynamic> json) {
    return MetasMetricas(
      llamadasAtendidas: (json['llamadas_atendidas'] as num?)?.toInt() ?? 50,
      ventasRealizadas: (json['ventas_realizadas'] as num?)?.toInt() ?? 15,
      tiempoPromedioLlamada: (json['tiempo_promedio_llamada'] as num?)?.toInt() ?? 180,
      llamadasPorHora: (json['llamadas_por_hora'] as num?)?.toInt() ?? 6,
      cumplimiento: (json['cumplimiento'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'llamadas_atendidas': llamadasAtendidas,
      'ventas_realizadas': ventasRealizadas,
      'tiempo_promedio_llamada': tiempoPromedioLlamada,
      'llamadas_por_hora': llamadasPorHora,
      'cumplimiento': cumplimiento,
    };
  }
}

/// Series de datos por hora
class SeriesMetricas {
  final List<LlamadaHoraSerie> llamadasPorHora;

  SeriesMetricas({
    required this.llamadasPorHora,
  });

  factory SeriesMetricas.fromJson(Map<String, dynamic> json) {
    final llamadasList = json['llamadas_por_hora'] as List<dynamic>?;
    
    return SeriesMetricas(
      llamadasPorHora: llamadasList
          ?.map((item) => LlamadaHoraSerie.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'llamadas_por_hora': llamadasPorHora.map((item) => item.toJson()).toList(),
    };
  }
}

/// Punto de dato individual para la serie de llamadas por hora
class LlamadaHoraSerie {
  final String hora; // "09:00"
  final int valor;

  LlamadaHoraSerie({
    required this.hora,
    required this.valor,
  });

  factory LlamadaHoraSerie.fromJson(Map<String, dynamic> json) {
    return LlamadaHoraSerie(
      hora: json['hora']?.toString() ?? '',
      valor: (json['valor'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hora': hora,
      'valor': valor,
    };
  }

  /// Extrae la hora como número (ej: "09:00" -> 9)
  int get horaNumero {
    try {
      final partes = hora.split(':');
      return int.parse(partes[0]);
    } catch (e) {
      return 0;
    }
  }
}
