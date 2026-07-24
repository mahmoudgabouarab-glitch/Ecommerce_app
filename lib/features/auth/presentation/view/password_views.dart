import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/repo/auth_repo_impl.dart';
import '../view_model/password_cubit/password_cubit.dart';

// ---------------------------------------------------------------------------
// Forgot password (request code)
// ---------------------------------------------------------------------------
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    return BlocProvider(
      create: (_) => PasswordCubit(getIt<AuthRepoImpl>()),
      child: Scaffold(
        appBar: AppBar(title: Text('forgot_password'.tr())),
        body: SafeArea(
          child: BlocConsumer<PasswordCubit, PasswordState>(
            listener: (context, state) {
              if (state is ForgotSuccess) {
                push(context,
                    ResetPasswordView(email: emailController.text.trim(), otp: state.otp));
              } else if (state is PasswordFailure) {
                showSnackBar(context, state.error);
              }
            },
            builder: (context, state) => SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Icon(Icons.lock_reset_rounded,
                      color: AppColors.primary, size: 56.r),
                  SizedBox(height: 20.h),
                  Text('reset_password'.tr(), style: AppStyles.bold24),
                  SizedBox(height: 8.h),
                  Text('forgot_subtitle'.tr(),
                      style: AppStyles.regular14
                          .copyWith(color: AppStyles.muted(context))),
                  SizedBox(height: 28.h),
                  CustomTextField(
                    controller: emailController,
                    hint: 'email'.tr(),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 28.h),
                  CustomButton(
                    text: 'send_code'.tr(),
                    isLoading: state is PasswordLoading,
                    onPressed: () =>
                        context.read<PasswordCubit>().forgot(emailController.text.trim()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reset password (enter code + new password)
// ---------------------------------------------------------------------------
class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key, required this.email, required this.otp});

  final String email;
  final String otp;

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController(text: otp);
    final passController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return BlocProvider(
      create: (_) => PasswordCubit(getIt<AuthRepoImpl>()),
      child: Scaffold(
        appBar: AppBar(title: Text('reset_password'.tr())),
        body: SafeArea(
          child: BlocConsumer<PasswordCubit, PasswordState>(
            listener: (context, state) {
              if (state is PasswordDone) {
                showSnackBar(context, 'password_reset_done'.tr(), success: true);
                Navigator.of(context).popUntil((r) => r.isFirst);
              } else if (state is PasswordFailure) {
                showSnackBar(context, state.error);
              }
            },
            builder: (context, state) => SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    Text('reset_subtitle'.tr(),
                        style: AppStyles.regular14
                            .copyWith(color: AppStyles.muted(context))),
                    SizedBox(height: 12.h),
                    if (otp.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text('demo_code'.tr(args: [otp]),
                            style: AppStyles.regular12
                                .copyWith(color: AppColors.primary)),
                      ),
                    SizedBox(height: 20.h),
                    CustomTextField(
                        controller: otpController,
                        hint: 'reset_code'.tr(),
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: passController,
                      hint: 'new_password'.tr(),
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) => (v != null && v.length >= 6)
                          ? null
                          : 'password_min'.tr(),
                    ),
                    SizedBox(height: 28.h),
                    CustomButton(
                      text: 'reset_password'.tr(),
                      isLoading: state is PasswordLoading,
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        context.read<PasswordCubit>().reset(
                              email: email,
                              otp: otpController.text.trim(),
                              password: passController.text,
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Change password (logged-in user)
// ---------------------------------------------------------------------------
class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentController = TextEditingController();
    final passController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return BlocProvider(
      create: (_) => PasswordCubit(getIt<AuthRepoImpl>()),
      child: Scaffold(
        appBar: AppBar(title: Text('change_password'.tr())),
        body: SafeArea(
          child: BlocConsumer<PasswordCubit, PasswordState>(
            listener: (context, state) {
              if (state is PasswordDone) {
                showSnackBar(context, 'password_changed'.tr(), success: true);
                Navigator.pop(context);
              } else if (state is PasswordFailure) {
                showSnackBar(context, state.error);
              }
            },
            builder: (context, state) => SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    CustomTextField(
                        controller: currentController,
                        hint: 'current_password'.tr(),
                        icon: Icons.lock_outline,
                        isPassword: true),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: passController,
                      hint: 'new_password'.tr(),
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      validator: (v) => (v != null && v.length >= 6)
                          ? null
                          : 'password_min'.tr(),
                    ),
                    SizedBox(height: 28.h),
                    CustomButton(
                      text: 'save_changes'.tr(),
                      isLoading: state is PasswordLoading,
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        context.read<PasswordCubit>().change(
                              currentPassword: currentController.text,
                              password: passController.text,
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
