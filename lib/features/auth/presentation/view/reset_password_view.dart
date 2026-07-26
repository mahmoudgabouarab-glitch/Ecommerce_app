import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/service_locator.dart';
import '../../data/repo/auth_repo_impl.dart';
import '../view_model/password_cubit/password_cubit.dart';
import 'widgets/password/reset_password_body.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key, required this.email, required this.otp});

  final String email;
  final String otp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordCubit(getIt<AuthRepoImpl>()),
      child: Scaffold(
        appBar: AppBar(title: Text('reset_password'.tr())),
        body: SafeArea(child: ResetPasswordBody(email: email, otp: otp)),
      ),
    );
  }
}
