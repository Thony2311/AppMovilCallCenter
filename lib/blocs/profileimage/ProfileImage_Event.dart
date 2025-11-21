/* ignore_for_file: file_names

part of 'ProfileImageBloc.dart';

abstract class ProfileImageEvent extends Equatable {
  const ProfileImageEvent();

  @override
  List<Object> get props => [];
}

class PickProfileImage extends ProfileImageEvent {}

class UploadProfileImage extends ProfileImageEvent {
  final File imageFile;
  final String userId;
  final String userRole;
  final String? oldImageUrl;

  const UploadProfileImage({
    required this.imageFile,
    required this.userId,
    required this.userRole,
    this.oldImageUrl,
  });

  @override
  List<Object> get props => [imageFile, userId, userRole];
}

*/