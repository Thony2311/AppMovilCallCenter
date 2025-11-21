// services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestGalleryPermission() async {
    var status = await Permission.photos.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Abrir configuración de la app
      await openAppSettings();
    }
    return false;
  }

  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }
}