/* bloc/profile_image_state.dart

part of 'ProfileImageBloc.dart';


abstract class ProfileImageState extends Equatable {
  const ProfileImageState();

  @override
  List<Object> get props => [];
}

class ProfileImageInitial extends ProfileImageState {}

class ProfileImageLoading extends ProfileImageState {}

class ProfileImagePicked extends ProfileImageState {
  final File imageFile;

  const ProfileImagePicked(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class ProfileImageUploading extends ProfileImageState {}

class ProfileImageUploadSuccess extends ProfileImageState {
  final String imageUrl;

  const ProfileImageUploadSuccess(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class ProfileImageError extends ProfileImageState {
  final String message;

  const ProfileImageError(this.message);

  @override
  List<Object> get props => [message];
}*/