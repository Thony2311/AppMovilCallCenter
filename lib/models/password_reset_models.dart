/// Modelo para solicitud de recuperación de contraseña
class PasswordResetRequestModel {
  /// Email del usuario que solicita recuperar contraseña
  final String email;

  PasswordResetRequestModel({required this.email});

  /// Convierte el modelo a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

/// Modelo para validar token de recuperación
class PasswordResetValidateModel {
  /// Token de recuperación a validar
  final String token;

  PasswordResetValidateModel({required this.token});

  /// Convierte el modelo a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}

/// Modelo para confirmar el reseteo de contraseña
class PasswordResetConfirmModel {
  /// Token de recuperación recibido por email
  final String token;
  
  /// Nueva contraseña (8-16 caracteres)
  final String newPassword;
  
  /// Confirmación de la nueva contraseña
  final String confirmPassword;

  PasswordResetConfirmModel({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  /// Convierte el modelo a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }

  /// Valida que las contraseñas coincidan
  bool get passwordsMatch => newPassword == confirmPassword;

  /// Valida que la contraseña cumpla con los requisitos mínimos
  /// - Al menos 8 caracteres
  /// - Máximo 16 caracteres
  bool get isValidLength => 
    newPassword.length >= 8 && newPassword.length <= 16;
  
  /// Valida que la contraseña sea válida
  bool get isValid => passwordsMatch && isValidLength;
}
