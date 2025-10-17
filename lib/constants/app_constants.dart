import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D47A1); // Azul profundo
  static const Color secondary = Color(0xFFE3F2FD); // Azul cielo claro
  static const Color accent = Color(0xFF42A5F5); // Azul vibrante
  static const Color background = Color(0xFFF7F9FC); // Blanco azulado
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro
  static const Color textPrimary = Color(0xFF0A0E21); // Texto principal
  static const Color textSecondary = Color(0xFF546E7A,); // Texto secundario gris-azulado
  static const Color inputBackground = Color(0xFFEDF2F7); // Fondo de campos
  static const Color success = Color(0xFF2E7D32); // Verde éxito
  static const Color error = Color(0xFFD32F2F); // Rojo error
  static const Color tertiary = Color.fromARGB(255, 66, 6, 78);

  static const Color reportadas = Color(0xFF3A82F7); // Azul
  static const Color auditadas = Color(0xFF5AC8B4);  // Teal
  static const Color pendientes = Color(0xFFFFAA5A);  // Naranja

  //Tema oscuro
   static const Color primaryDark = Color(0xFF1565C0);
  static const Color secondaryDark = Color(0xFF0D1B2A);
  static const Color accentDark = Color(0xFF64B5F6);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0BEC5);
  static const Color inputBackgroundDark = Color(0xFF2D2D2D);
}

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.subtitle,
        bodyMedium: AppTextStyles.body,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.accentDark,
        surface: AppColors.surfaceDark,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
      ),
      textTheme: const TextTheme(
        titleLarge: AppTextStyles.titleDark,
        titleMedium: AppTextStyles.subtitleDark,
        bodyMedium: AppTextStyles.bodyDark,
      ),
    );
  }
}



class AppTextStyles {
  //Tema claro
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

  static const TextStyle headers = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  //Tema Oscuro
  static const TextStyle titleDark = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark
  );
  static const TextStyle subtitleDark = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimaryDark,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyDark = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondaryDark,
  );
}

class AppConfig {
  static const double borderRadius = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 200);
}


class AppSettings {
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String spanish = 'es';
  static const String english = 'en';
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
  borderSide: const BorderSide(color: Colors.blueGrey, ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
  borderSide: const BorderSide(color: Colors.blueGrey, ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
  borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
  borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
  borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      filled: true,
      fillColor: AppColors.inputBackground,
    );
  }
}