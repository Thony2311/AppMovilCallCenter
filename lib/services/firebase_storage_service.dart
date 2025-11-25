import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Servicio para gestionar archivos en Firebase Storage
///
/// Este servicio maneja la subida y descarga de fotos de perfil
/// almacenadas en Firebase Storage
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una foto de perfil a Firebase Storage
  ///
  /// [userId] - ID del usuario (documento_id)
  /// [imageFile] - Archivo de imagen a subir
  /// 
  /// Retorna la URL de descarga de la imagen subida
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Leer los bytes del archivo
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Crear una referencia al archivo en Firebase Storage
      // Ruta: profile_pictures/{userId}/profile.jpg
      final Reference storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child(userId)
          .child('profile.jpg');

      // Configurar metadata con tipo de contenido
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'userId': userId,
        },
      );

      // Subir el archivo
      final UploadTask uploadTask = storageRef.putData(imageBytes, metadata);

      // Esperar a que se complete la subida
      final TaskSnapshot snapshot = await uploadTask;

      // Obtener la URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Imagen subida exitosamente: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error al subir imagen: $e');
      rethrow;
    }
  }

  /// Descarga una foto de perfil de Firebase Storage
  ///
  /// [downloadUrl] - URL de descarga de Firebase Storage
  /// 
  /// Retorna los bytes de la imagen
  Future<Uint8List?> downloadProfilePicture(String downloadUrl) async {
    try {
      // Crear referencia desde la URL de descarga
      final Reference ref = _storage.refFromURL(downloadUrl);

      // Descargar los bytes
      final Uint8List? data = await ref.getData();

      if (data != null) {
        debugPrint('✅ Imagen descargada exitosamente: ${data.length} bytes');
      }

      return data;
    } catch (e) {
      debugPrint('❌ Error al descargar imagen: $e');
      return null;
    }
  }

  /// Elimina una foto de perfil de Firebase Storage
  ///
  /// [userId] - ID del usuario (documento_id)
  Future<void> deleteProfilePicture(String userId) async {
    try {
      final Reference storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child(userId)
          .child('profile.jpg');

      await storageRef.delete();
      debugPrint('✅ Imagen eliminada exitosamente');
    } catch (e) {
      debugPrint('❌ Error al eliminar imagen: $e');
      // No lanzar error si la imagen no existe
      if (e is FirebaseException && e.code != 'object-not-found') {
        rethrow;
      }
    }
  }

  /// Verifica si existe una foto de perfil para un usuario
  ///
  /// [userId] - ID del usuario (documento_id)
  Future<bool> profilePictureExists(String userId) async {
    try {
      final Reference storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child(userId)
          .child('profile.jpg');

      // Intentar obtener metadata del archivo
      await storageRef.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la URL de descarga de una foto de perfil existente
  ///
  /// [userId] - ID del usuario (documento_id)
  /// 
  /// Retorna null si no existe la imagen
  Future<String?> getProfilePictureUrl(String userId) async {
    try {
      final Reference storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child(userId)
          .child('profile.jpg');

      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('⚠️ No se encontró foto de perfil para el usuario: $userId');
      return null;
    }
  }
}
