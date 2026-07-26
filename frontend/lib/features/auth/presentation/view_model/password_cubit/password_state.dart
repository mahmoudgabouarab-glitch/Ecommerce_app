part of 'password_cubit.dart';

sealed class PasswordState extends Equatable {
  const PasswordState();

  @override
  List<Object?> get props => [];
}

final class PasswordInitial extends PasswordState {}

final class PasswordLoading extends PasswordState {}

final class ForgotSuccess extends PasswordState {}

final class PasswordDone extends PasswordState {}

final class PasswordFailure extends PasswordState {
  final String error;
  const PasswordFailure(this.error);

  @override
  List<Object?> get props => [error];
}
