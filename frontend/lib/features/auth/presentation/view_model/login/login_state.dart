part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final AuthModel auth;
  const LoginSuccess(this.auth);

  @override
  List<Object> get props => [auth];
}

final class LoginNeedsVerification extends LoginState {
  final String email;
  const LoginNeedsVerification(this.email);

  @override
  List<Object> get props => [email];
}

final class LoginFailure extends LoginState {
  final String error;
  const LoginFailure(this.error);

  @override
  List<Object> get props => [error];
}
