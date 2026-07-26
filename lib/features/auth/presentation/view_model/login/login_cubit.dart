import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/user_cache.dart';
import '../../../data/models/auth_model.dart';
import '../../../data/repo/auth_repo.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repo) : super(LoginInitial());

  final AuthRepo _repo;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    emit(LoginLoading());
    final result = await _repo.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    await result.fold(
      (failure) async {
        if (failure is EmailNotVerifiedFailure) {
          emit(LoginNeedsVerification(failure.email));
        } else {
          emit(LoginFailure(failure.errorMessage));
        }
      },
      (auth) async {
        await UserCache.save(auth.user, token: auth.token);
        emit(LoginSuccess(auth));
      },
    );
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
