/// Modelo para solicitud de cambio de contraseña
/// 
/// Este modelo se usa cuando un usuario quiere cambiar su contraseña
class ChangePasswordRequestModel {
  /// Contraseña actual del usuario
  final String oldPassword;
  
  /// Nueva contraseña deseada
  final String newPassword;
  
  /// Confirmación de la nueva contraseña
  final String newPasswordConfirm;

  ChangePasswordRequestModel({
    required this.oldPassword,
    required this.newPassword,
    required this.newPasswordConfirm,
  });

  /// Convierte el modelo a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirm': newPasswordConfirm,
    };
  }

  /// Verifica si las contraseñas nuevas coinciden
  bool get passwordsMatch => newPassword == newPasswordConfirm;

  /// Valida que la contraseña nueva tenga al menos 8 caracteres
  bool get isValidLength => newPassword.length >= 8;

  /// Valida que las contraseñas no estén vacías
  bool get isNotEmpty => 
    oldPassword.isNotEmpty && 
    newPassword.isNotEmpty && 
    newPasswordConfirm.isNotEmpty;

  /// Validación completa
  bool get isValid => isNotEmpty && passwordsMatch && isValidLength;

  /// Obtiene el mensaje de error si no es válido
  String? get validationError {
    if (!isNotEmpty) {
      return 'Todos los campos son requeridos';
    }
    if (!passwordsMatch) {
      return 'Las contraseñas nuevas no coinciden';
    }
    if (!isValidLength) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }
}
