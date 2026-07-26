import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/service_locator.dart';
import '../../data/repo/auth_repo_impl.dart';
import '../view_model/password_cubit/password_cubit.dart';
import 'widgets/password/forgot_password_body.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordCubit(getIt<AuthRepoImpl>()),
      child: Scaffold(
        appBar: AppBar(title: Text('forgot_password'.tr())),
        body: const SafeArea(child: ForgotPasswordBody()),
      ),
    );
  }
}
