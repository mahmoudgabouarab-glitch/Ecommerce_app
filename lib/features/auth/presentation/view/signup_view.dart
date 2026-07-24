import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/service_locator.dart';
import '../../data/repo/auth_repo_impl.dart';
import '../view_model/signup/signup_cubit.dart';
import 'widgets/signup/signup_body.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignupCubit(getIt<AuthRepoImpl>()),
      child: Scaffold(
        appBar: AppBar(),
        body: const SafeArea(child: SignupBody()),
      ),
    );
  }
}
