import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/network/cache_helper.dart';
import '../../../../../core/network/cache_keys.dart';
import '../../../../../core/network/secure_store.dart';
import '../../../../../core/utils/user_cache.dart';
import '../../../data/models/auth_model.dart';
import '../../../data/repo/auth_repo.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repo) : super(LoginInitial()) {
    _restorePassword();
  }

  final AuthRepo _repo;

  final emailController = TextEditingController(
    text: CacheHelper.getData(key: CacheKeys.lastEmail) as String? ?? '',
  );
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> _restorePassword() async {
    await CacheHelper.removeData(key: 'lastPassword');
    final saved = await SecureStore.readLastPassword();
    if (saved != null && saved.isNotEmpty) passwordController.text = saved;
  }

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
        await CacheHelper.saveData(
            key: CacheKeys.lastEmail, value: emailController.text.trim());
        await SecureStore.saveLastPassword(passwordController.text);
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
