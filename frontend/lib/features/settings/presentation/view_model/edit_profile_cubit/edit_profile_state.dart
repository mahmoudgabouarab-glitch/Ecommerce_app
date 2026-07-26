part of 'edit_profile_cubit.dart';

sealed class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

final class EditProfileInitial extends EditProfileState {
  final String? avatarUrl;
  const EditProfileInitial(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

final class EditProfileImagePicked extends EditProfileState {
  final String path;
  const EditProfileImagePicked(this.path);

  @override
  List<Object?> get props => [path];
}

final class EditProfileChanged extends EditProfileState {
  @override
  List<Object?> get props => [DateTime.now().microsecondsSinceEpoch];
}

final class EditProfileSaving extends EditProfileState {}

final class EditProfileSuccess extends EditProfileState {}

final class EditProfileFailure extends EditProfileState {
  final String error;
  const EditProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}
