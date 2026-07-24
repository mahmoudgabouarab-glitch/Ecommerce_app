part of 'signup_cubit.dart';

sealed class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object> get props => [];
}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

final class SignupImagePicked extends SignupState {
  final String path;
  const SignupImagePicked(this.path);

  @override
  List<Object> get props => [path];
}

final class SignupSuccess extends SignupState {
  final AuthModel auth;
  const SignupSuccess(this.auth);

  @override
  List<Object> get props => [auth];
}

final class SignupFailure extends SignupState {
  final String error;
  const SignupFailure(this.error);

  @override
  List<Object> get props => [error];
}
