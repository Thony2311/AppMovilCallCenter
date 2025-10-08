import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1565C0); // Azul principal
  static const Color secondary = Color(0xFFE6F0FA); // Azul claro
  static const Color accent = Color(0xFF42A5F5); // Azul intermedio
  static const Color background = Color(0xFFF3F6FB);
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
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
