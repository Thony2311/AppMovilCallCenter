import 'dart:developer' as developer;

/// Wrapper simple para logging del proyecto.
/// Provee métodos con nombres en inglés para usar en el código.
class AppLogger {
  AppLogger._();

  static void info(String message, {String name = 'App', int level = 800}) {
    developer.log(message, name: name, level: level);
  }

  static void warn(String message, {String name = 'App', int level = 900}) {
    developer.log(message, name: name, level: level);
  }

  static void error(String message, {String name = 'App', int level = 1000}) {
    developer.log(message, name: name, level: level);
  }

  static void debug(String message, {String name = 'App', int level = 700}) {
    developer.log(message, name: name, level: level);
  }
}
