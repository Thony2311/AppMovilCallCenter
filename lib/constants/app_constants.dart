import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D47A1); // Azul profundo
  static const Color secondary = Color(0xFFE3F2FD); // Azul cielo claro
  static const Color accent = Color(0xFF42A5F5); // Azul vibrante
  static const Color background = Color(0xFFF7F9FC); // Blanco azulado
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro
  static const Color textPrimary = Color(0xFF0A0E21); // Texto principal
  static const Color textSecondary = Color(
    0xFF546E7A,
  ); // Texto secundario gris-azulado
  static const Color inputBackground = Color(0xFFEDF2F7); // Fondo de campos
  static const Color success = Color(0xFF2E7D32); // Verde éxito
  static const Color error = Color(0xFFD32F2F); // Rojo error
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}

class AppConfig {
  static const double borderRadius = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 200);
}

class AppInputDecorations {
  static InputDecoration textField({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.blueGrey, // Color azul principal
      ),
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: Colors.blueGrey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: Colors.blueGrey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      filled: true,
      fillColor: AppColors.inputBackground,
    );
  }
}