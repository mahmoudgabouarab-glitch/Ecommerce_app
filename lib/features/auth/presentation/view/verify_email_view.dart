import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/service_locator.dart';
import '../../data/repo/auth_repo_impl.dart';
import '../view_model/verify_email/verify_email_cubit.dart';
import 'widgets/verify/verify_email_body.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerifyEmailCubit(getIt<AuthRepoImpl>(), email),
      child: Scaffold(
        appBar: AppBar(title: Text('verify_email'.tr())),
        body: const SafeArea(child: VerifyEmailBody()),
      ),
    );
  }
}
