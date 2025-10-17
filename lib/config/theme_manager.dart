import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeManager() {
    _loadTheme();
  }

  // Carga el tema desde las preferencias compartidas
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(AppSettings.themeKey) ?? AppSettings.lightTheme;
    _themeMode = theme == AppSettings.darkTheme ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // guarda el tema en las preferencias compartidas
  Future<void> _saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppSettings.themeKey,
      themeMode == ThemeMode.dark ? AppSettings.darkTheme : AppSettings.lightTheme,
    );
  }

  // establece el tema
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _saveTheme(themeMode);
    notifyListeners();
  }

  // alternar entre temas claro y oscuro
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme(_themeMode);
    notifyListeners();
  }

  // metodos estáticos para obtener y establecer el tema sin instanciar ThemeManager
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(AppSettings.themeKey) ?? AppSettings.lightTheme;
    return theme == AppSettings.darkTheme ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppSettings.themeKey,
      themeMode == ThemeMode.dark ? AppSettings.darkTheme : AppSettings.lightTheme,
    );
  }
}