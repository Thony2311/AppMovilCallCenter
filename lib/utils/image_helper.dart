import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Utilidad para convertir imágenes entre diferentes formatos
///
/// Proporciona métodos para convertir entre File, Uint8List y Base64
class ImageHelper {
  /// Convierte un archivo de imagen a una cadena Base64
  ///
  /// [imageFile] - Archivo de imagen a convertir
  /// 
  /// Retorna una cadena Base64 de la imagen
  static Future<String> fileToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('❌ Error al convertir archivo a base64: $e');
      rethrow;
    }
  }

  /// Convierte bytes (Uint8List) a una cadena Base64
  ///
  /// [imageBytes] - Bytes de la imagen
  /// 
  /// Retorna una cadena Base64 de la imagen
  static String bytesToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  /// Convierte una cadena Base64 a bytes (Uint8List)
  ///
  /// [base64String] - Cadena Base64 de la imagen
  /// 
  /// Retorna los bytes de la imagen
  static Uint8List base64ToBytes(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('❌ Error al decodificar base64: $e');
      rethrow;
    }
  }

  /// Convierte una cadena Base64 a un archivo temporal
  ///
  /// [base64String] - Cadena Base64 de la imagen
  /// [filePath] - Ruta donde guardar el archivo temporal
  /// 
  /// Retorna el archivo creado
  static Future<File> base64ToFile(String base64String, String filePath) async {
    try {
      final bytes = base64Decode(base64String);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('❌ Error al convertir base64 a archivo: $e');
      rethrow;
    }
  }

  /// Valida si una cadena es un Base64 válido
  ///
  /// [base64String] - Cadena a validar
  /// 
  /// Retorna true si es un Base64 válido
  static bool isValidBase64(String base64String) {
    try {
      base64Decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Comprime una imagen reduciendo su calidad
  ///
  /// [imageBytes] - Bytes de la imagen original
  /// [quality] - Calidad de compresión (0-100)
  /// 
  /// Nota: Esta es una función placeholder. Para compresión real,
  /// considera usar el paquete 'flutter_image_compress'
  static Uint8List compressImage(Uint8List imageBytes, {int quality = 85}) {
    // TODO: Implementar compresión real si es necesario
    // Por ahora, retorna los bytes originales
    debugPrint('⚠️ Compresión de imagen no implementada. Usando imagen original.');
    return imageBytes;
  }

  /// Obtiene el tamaño de una imagen en bytes
  ///
  /// [imageFile] - Archivo de imagen
  /// 
  /// Retorna el tamaño en bytes
  static Future<int> getImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return bytes.length;
    } catch (e) {
      debugPrint('❌ Error al obtener tamaño de imagen: $e');
      rethrow;
    }
  }

  /// Formatea el tamaño de bytes a formato legible (KB, MB)
  ///
  /// [bytes] - Tamaño en bytes
  /// 
  /// Retorna una cadena formateada (ej: "2.5 MB")
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
