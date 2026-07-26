part of 'verify_email_cubit.dart';

sealed class VerifyEmailState extends Equatable {
  const VerifyEmailState();

  @override
  List<Object> get props => [];
}

final class VerifyEmailInitial extends VerifyEmailState {}

final class VerifyEmailLoading extends VerifyEmailState {}

final class VerifyEmailSuccess extends VerifyEmailState {
  final AuthModel auth;
  const VerifyEmailSuccess(this.auth);

  @override
  List<Object> get props => [auth];
}

final class VerifyEmailResent extends VerifyEmailState {}

final class VerifyEmailFailure extends VerifyEmailState {
  final String error;
  const VerifyEmailFailure(this.error);

  @override
  List<Object> get props => [error];
}
