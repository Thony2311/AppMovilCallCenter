class Venta {
  final int id;
  final String cliente;
  final String producto;
  final String agente;
  final String fecha;
  final String duracion;
  final String status;
  final double monto;
  final String? transcripcion;
  final int? llamadaId;
  final String? observaciones;

  Venta({
    required this.id,
    required this.cliente,
    required this.producto,
    required this.agente,
    required this.fecha,
    required this.duracion,
    required this.status,
    required this.monto,
    this.transcripcion,
    this.llamadaId,
    this.observaciones,
  });

  /// Parsea la respuesta JSON de la API
  factory Venta.fromJson(Map<String, dynamic> json) {
    // Usar helpers privados para parseo robusto
    String agenteNombre = _asString(json['agente'])
        .trim();

    if (agenteNombre.isEmpty) {
      // Intentar otros campos relacionados con agente
      if (json['agente_obj'] is Map) {
        agenteNombre = _asString((json['agente_obj'] as Map)['username'])
            .isNotEmpty
            ? _asString((json['agente_obj'] as Map)['username'])
            : _asString((json['agente_obj'] as Map)['nombre']);
      }
    }

    if (agenteNombre.isEmpty) {
      agenteNombre = _asString(json['agente_nombre']);
    }

    if (agenteNombre.isEmpty && json['agente_id'] != null) {
      agenteNombre = 'Agente ${json['agente_id']}';
    }

    if (agenteNombre.isEmpty) agenteNombre = 'Sin asignar';

    final fechaRaw = json['fecha'] ?? json['created_at'];
    final duracionRaw = json['duracion'];

    return Venta(
      id: (json['id'] is int) ? json['id'] as int : (int.tryParse('${json['id']}') ?? 0),
      cliente: _asString(json['cliente'], 'Sin nombre'),
      producto: _asString(json['producto'], 'Sin producto'),
      agente: agenteNombre,
      fecha: _parseFecha(fechaRaw),
      duracion: _parseDuration(duracionRaw),
      status: _parseStatus(json['status'] ?? 'pendiente'),
      monto: _parseDouble(json['monto'] ?? 0),
      transcripcion: json['transcripcion'] as String?,
      llamadaId: (json['llamada_id'] is int) ? json['llamada_id'] as int : (int.tryParse('${json['llamada_id']}') ),
      observaciones: json['observaciones'] as String?,
    );
  }

  // Helpers privados para parseo seguro
  static String _asString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is Map) {
      // Buscar claves comunes
      return (value['username'] ?? value['nombre'] ?? value['name'] ?? value['full_name'] ?? value['first_name'] ?? '')
          .toString();
    }
    if (value is List) return value.map((e) => e.toString()).join(', ');
    return value.toString();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      var v = value.trim();
      // Remover símbolos de moneda y espacios
      v = v.replaceAll(RegExp(r"[^0-9,.-]"), '');
      // Reemplazar coma decimal por punto si es necesario
      if (v.contains(',') && v.contains('.')) {
        // asumir que punto es separador de miles -> eliminar puntos
        v = v.replaceAll('.', '');
        v = v.replaceAll(',', '.');
      } else if (v.contains(',') && !v.contains('.')) {
        v = v.replaceAll(',', '.');
      }
      return double.tryParse(v) ?? 0.0;
    }
    return 0.0;
  }

  static String _parseDuration(dynamic dur) {
    if (dur == null) return '0 min';
    if (dur is int) {
      // interpretar como segundos
      final minutes = (dur / 60).floor();
      return '$minutes min';
    }
    if (dur is String) {
      final s = dur.trim();
      // formato HH:MM:SS o MM:SS
  if (RegExp(r'^\d{1,2}:\d{2}:\d{2}$').hasMatch(s) || RegExp(r'^\d{1,2}:\d{2}$').hasMatch(s)) {
        final parts = s.split(':').map((p) => int.tryParse(p) ?? 0).toList();
        int seconds = 0;
        if (parts.length == 3) seconds = parts[0] * 3600 + parts[1] * 60 + parts[2];
        if (parts.length == 2) seconds = parts[0] * 60 + parts[1];
        final minutes = (seconds / 60).floor();
        return '$minutes min';
      }
      // Si viene con sufijo 's' o 'm'
      final match = RegExp(r'(?:(\d+)\s*h)?\s*(?:(\d+)\s*m)?\s*(?:(\d+)\s*s)?', caseSensitive: false).firstMatch(s);
      if (match != null) {
        final h = int.tryParse(match.group(1) ?? '') ?? 0;
        final m = int.tryParse(match.group(2) ?? '') ?? 0;
        final sec = int.tryParse(match.group(3) ?? '') ?? 0;
        final totalMin = h * 60 + m + (sec > 0 ? 1 : 0);
        if (totalMin > 0) return '$totalMin min';
      }
      // fallback: intentar parsear como número de segundos
      final asNum = int.tryParse(s);
      if (asNum != null) return '${(asNum / 60).floor()} min';
      return s;
    }
    return dur.toString();
  }

  /// Convierte el modelo a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'producto': producto,
      'agente': agente,
      'fecha': fecha,
      'duracion': duracion,
      'status': status,
      'monto': monto,
      'transcripcion': transcripcion,
      'llamada_id': llamadaId,
      'observaciones': observaciones,
    };
  }

  /// Parsea el status a valores conocidos
  static String _parseStatus(dynamic status) {
    final statusStr = status.toString().toLowerCase();
    if (statusStr.contains('audit')) return 'auditada';
    if (statusStr.contains('report')) return 'reportada';
    if (statusStr.contains('pend')) return 'pendiente';
    if (statusStr.contains('aprob')) return 'auditada';
    if (statusStr.contains('rechaz')) return 'reportada';
    return statusStr;
  }

  /// (Deprecated) previously simple _parseDouble removed in favor of robust version above.

  /// Parsea la fecha a String legible
  static String _parseFecha(dynamic fecha) {
    if (fecha == null) return '';
    if (fecha is String) {
      try {
        // Si viene como ISO string (2025-10-09T10:30:00)
        final dateTime = DateTime.parse(fecha);
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      } catch (e) {
        // Si ya viene en formato legible
        return fecha;
      }
    }
    return fecha.toString();
  }
}
