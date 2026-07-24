import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repo.dart';

part 'password_state.dart';

class PasswordCubit extends Cubit<PasswordState> {
  PasswordCubit(this._repo) : super(PasswordInitial());

  final AuthRepo _repo;

  Future<void> forgot(String email) async {
    emit(PasswordLoading());
    final result = await _repo.forgotPassword(email);
    result.fold(
      (f) => emit(PasswordFailure(f.errorMessage)),
      (otp) => emit(ForgotSuccess(otp)),
    );
  }

  Future<void> reset({
    required String email,
    required String otp,
    required String password,
  }) async {
    emit(PasswordLoading());
    final result =
        await _repo.resetPassword(email: email, otp: otp, password: password);
    result.fold(
      (f) => emit(PasswordFailure(f.errorMessage)),
      (_) => emit(PasswordDone()),
    );
  }

  Future<void> change({
    required String currentPassword,
    required String password,
  }) async {
    emit(PasswordLoading());
    final result = await _repo.changePassword(
      currentPassword: currentPassword,
      password: password,
    );
    result.fold(
      (f) => emit(PasswordFailure(f.errorMessage)),
      (_) => emit(PasswordDone()),
    );
  }
}
