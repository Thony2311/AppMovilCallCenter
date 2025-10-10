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
    // Extraer el nombre del agente de diferentes posibles ubicaciones
    String agenteNombre = 'Sin asignar';
    
    if (json['agente'] != null) {
      // Si viene como string directo
      agenteNombre = json['agente'];
    } else if (json['agente_obj'] != null && json['agente_obj'] is Map) {
      // Si viene como objeto relacionado
      final agenteObj = json['agente_obj'] as Map<String, dynamic>;
      agenteNombre = agenteObj['username'] ?? 
                     agenteObj['nombre'] ?? 
                     'Agente ${json['agente_id']}';
    } else if (json['agente_nombre'] != null) {
      // Si viene como campo separado
      agenteNombre = json['agente_nombre'];
    } else if (json['agente_id'] != null) {
      // Fallback: mostrar el ID
      agenteNombre = 'Agente ${json['agente_id']}';
    }
    
    return Venta(
      id: json['id'] ?? 0,
      cliente: json['cliente'] ?? 'Sin nombre',
      producto: json['producto'] ?? 'Sin producto',
      agente: agenteNombre,
      fecha: _parseFecha(json['fecha'] ?? json['created_at']),
      duracion: json['duracion'] ?? '0 min',
      status: _parseStatus(json['status'] ?? 'pendiente'),
      monto: _parseDouble(json['monto'] ?? 0),
      transcripcion: json['transcripcion'] as String?,
      llamadaId: json['llamada_id'] as int?,
      observaciones: json['observaciones'] as String?,
    );
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

  /// Parsea valores numéricos que puedan venir como String
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

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
