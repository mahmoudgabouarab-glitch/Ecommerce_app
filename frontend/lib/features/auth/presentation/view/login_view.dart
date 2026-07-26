import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/service_locator.dart';
import '../../data/repo/auth_repo_impl.dart';
import '../view_model/login/login_cubit.dart';
import 'widgets/login/login_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(getIt<AuthRepoImpl>()),
      child: const Scaffold(body: SafeArea(child: LoginBody())),
    );
  }
}
