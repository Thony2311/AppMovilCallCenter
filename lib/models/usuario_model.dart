import 'estado_agente_actual_model.dart';

/// Modelo para representar un usuario autenticado
/// 
/// Este modelo contiene toda la información del usuario que retorna el backend
/// después de un login exitoso.
class UsuarioModel {
  /// Identificador único del usuario (documento de identidad)
  final String documentoId;
  
  /// Correo electrónico del usuario (único en el sistema)
  final String email;
  
  /// Primer nombre del usuario
  final String firstName;
  
  /// Apellido del usuario
  final String lastName;
  
  /// Nombre completo (computed field)
  final String fullName;
  
  /// Número de teléfono (opcional)
  final String? phone;
  
  /// URL de la foto de perfil (opcional)
  final String? fotoPerfil;
  
  /// Rol del usuario en el sistema
  /// Valores posibles: AGENTE, COORDINADOR, JEFE_CAMPANA, BACKOFFICE, ADMIN, JEFE_CENTRO
  final String role;
  
  /// Indica si el usuario está activo en el sistema
  final bool isActive;
  
  /// Indica si el usuario es staff (tiene acceso al admin)
  final bool isStaff;
  
  /// Indica si el usuario es superusuario
  final bool isSuperuser;
  
  /// Fecha de registro del usuario (opcional)
  final DateTime? dateJoined;
  
  /// Fecha del último login (opcional)
  final DateTime? lastLogin;
  
  /// Estado actual del agente (solo para agentes)
  final EstadoAgenteActualModel? estadoActual;

  UsuarioModel({
    required this.documentoId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.phone,
    this.fotoPerfil,
    required this.role,
    required this.isActive,
    required this.isStaff,
    required this.isSuperuser,
    this.dateJoined,
    this.lastLogin,
    this.estadoActual,
  });

  /// Factory constructor para crear un UsuarioModel desde JSON
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      documentoId: _asString(json['documento_id'] ?? json['id'] ?? '') ?? '',
      email: _asString(json['email']) ?? '',
      firstName: _asString(json['first_name']) ?? '',
      lastName: _asString(json['last_name']) ?? '',
      fullName: _asString(json['full_name']) ?? '',
      phone: _asString(json['phone']),
      fotoPerfil: _asString(json['foto_perfil']),
      role: _asString(json['role']) ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 'true',
      isStaff: json['is_staff'] == true || json['is_staff'] == 'true',
      isSuperuser: json['is_superuser'] == true || json['is_superuser'] == 'true',
      dateJoined: json['date_joined'] != null 
        ? DateTime.tryParse(json['date_joined'].toString()) 
        : null,
      lastLogin: json['last_login'] != null 
        ? DateTime.tryParse(json['last_login'].toString()) 
        : null,
      estadoActual: json['estado_actual'] != null
        ? EstadoAgenteActualModel.fromJson(json['estado_actual'] as Map<String, dynamic>)
        : null,
    );
  }

  // Helper interno para convertir a String de forma segura
  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'documento_id': documentoId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'phone': phone,
      'foto_perfil': fotoPerfil,
      'role': role,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'date_joined': dateJoined?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'estado_actual': estadoActual?.toJson(),
    };
  }

  /// Crea una copia del modelo con algunos campos modificados
  UsuarioModel copyWith({
    String? documentoId,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phone,
    String? fotoPerfil,
    String? role,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    DateTime? dateJoined,
    DateTime? lastLogin,
    EstadoAgenteActualModel? estadoActual,
  }) {
    return UsuarioModel(
      documentoId: documentoId ?? this.documentoId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      estadoActual: estadoActual ?? this.estadoActual,
    );
  }

  /// Verifica si el usuario es agente
  bool get isAgent => role.toUpperCase() == 'AGENTE';

  /// Verifica si el usuario es coordinador
  bool get isCoordinator => role.toUpperCase() == 'COORDINADOR';

  /// Verifica si el usuario es jefe de campaña
  bool get isJefeCampana => role.toUpperCase() == 'JEFE_CAMPANA' || role.toUpperCase() == 'JEFE DE CAMPAÑA';

  /// Verifica si el usuario es backoffice
  bool get isBackoffice => role.toUpperCase() == 'BACKOFFICE';

  /// Verifica si el usuario es administrador
  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  /// Verifica si el usuario es jefe de centro
  bool get isJefeCentro => role.toUpperCase() == 'JEFE_CENTRO' || role.toUpperCase() == 'JEFE DE CENTRO';

  /// Retrocompatibilidad: username apunta a email
  @Deprecated('Usar email en su lugar')
  String get username => email;

  /// Retrocompatibilidad: nombre apunta a fullName
  @Deprecated('Usar fullName en su lugar')
  String get nombre => fullName;
}
