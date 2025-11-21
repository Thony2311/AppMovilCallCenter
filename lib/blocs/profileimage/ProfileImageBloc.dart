/*
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:call_center_application/services/PermissionService.dart';
import 'package:equatable/equatable.dart';
import 'package:call_center_application/services/Firebase/FirebaseStorageService.dart';
part 'ProfileImage_State.dart';
part 'ProfileImage_event.dart';

class ProfileImageBloc extends Bloc<ProfileImageEvent, ProfileImageState> {
  final FirebaseStorageService _storageService;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileImageBloc(this._storageService) : super(ProfileImageInitial()) {
    on<PickProfileImage>(_onPickProfileImage);
    on<UploadProfileImage>(_onUploadProfileImage);
  }

  void _onPickProfileImage(
    PickProfileImage event,
    Emitter<ProfileImageState> emit,
  ) async {
    emit(ProfileImageLoading());
    
    try {
      // Solicitar permisos
      bool hasPermission = await PermissionService.requestGalleryPermission();
      if (!hasPermission) {
        emit(const ProfileImageError('Permiso denegado para acceder a la galería'));
        return;
      }

      // Seleccionar imagen
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        emit(ProfileImagePicked(File(image.path)));
      } else {
        emit(ProfileImageInitial());
      }
    } catch (e) {
      emit(ProfileImageError('Error al seleccionar imagen: $e'));
    }
  }

  void _onUploadProfileImage(
    UploadProfileImage event,
    Emitter<ProfileImageState> emit,
  ) async {
    emit(ProfileImageUploading());
    
    try {
      // Subir imagen a Firebase Storage
      String? imageUrl = await _storageService.uploadProfileImage(
        imageFile: event.imageFile,
        userId: event.userId,
        userRole: event.userRole,
      );

      if (imageUrl != null) {
        // Eliminar imagen anterior si existe
        if (event.oldImageUrl != null) {
          await _storageService.deleteOldProfileImage(event.oldImageUrl!);
        }
        
        emit(ProfileImageUploadSuccess(imageUrl));
      } else {
        emit(const ProfileImageError('Error al subir la imagen'));
      }
    } catch (e) {
      emit(ProfileImageError('Error al subir imagen: $e'));
    }
  }
}*/