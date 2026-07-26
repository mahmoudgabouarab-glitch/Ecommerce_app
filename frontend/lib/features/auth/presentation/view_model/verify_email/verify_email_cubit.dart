import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/user_cache.dart';
import '../../../data/models/auth_model.dart';
import '../../../data/repo/auth_repo.dart';

part 'verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit(this._repo, this.email) : super(VerifyEmailInitial());

  final AuthRepo _repo;
  final String email;

  final codeController = TextEditingController();

  Future<void> verify() async {
    final code = codeController.text.trim();
    if (code.length < 6) {
      emit(const VerifyEmailFailure('Enter the 6-digit code.'));
      return;
    }

    emit(VerifyEmailLoading());
    final result = await _repo.verifyEmail(email: email, code: code);

    await result.fold(
      (failure) async => emit(VerifyEmailFailure(failure.errorMessage)),
      (auth) async {
        await UserCache.save(auth.user, token: auth.token);
        emit(VerifyEmailSuccess(auth));
      },
    );
  }

  Future<void> resend() async {
    final result = await _repo.resendCode(email);
    result.fold(
      (failure) => emit(VerifyEmailFailure(failure.errorMessage)),
      (_) => emit(VerifyEmailResent()),
    );
  }

  @override
  Future<void> close() {
    codeController.dispose();
    return super.close();
  }
}
