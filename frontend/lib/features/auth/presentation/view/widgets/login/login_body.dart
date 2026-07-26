import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/network/cache_helper.dart';
import '../../../../../../core/network/cache_keys.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../../../main_layout.dart';
import '../../../view_model/login/login_cubit.dart';
import '../../forgot_password_view.dart';
import '../../signup_view.dart';
import '../../verify_email_view.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    final muted = AppStyles.muted(context);

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          pushAndRemoveUntil(context, const MainLayout());
        } else if (state is LoginNeedsVerification) {
          push(context, VerifyEmailView(email: state.email));
        } else if (state is LoginFailure) {
          showSnackBar(context, state.error);
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Form(
          key: cubit.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.brandGradient),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(Icons.shopping_bag_rounded,
                    color: Colors.white, size: 32.r),
              ),
              SizedBox(height: 26.h),
              Text('welcome_back'.tr(), style: AppStyles.bold28),
              SizedBox(height: 8.h),
              Text('sign_in_subtitle'.tr(),
                  style: AppStyles.regular14.copyWith(color: muted)),
              SizedBox(height: 34.h),
              _label('email'.tr(), muted),
              CustomTextField(
                controller: cubit.emailController,
                hint: 'you@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v != null && v.contains('@')) ? null : 'enter_valid_email'.tr(),
              ),
              SizedBox(height: 18.h),
              _label('password'.tr(), muted),
              CustomTextField(
                controller: cubit.passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) => (v != null && v.length >= 6)
                    ? null
                    : 'password_min'.tr(),
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () =>
                      push(context, const ForgotPasswordView()),
                  child: Text('forgot_password'.tr(),
                      style: AppStyles.semiBold14
                          .copyWith(color: AppColors.primary)),
                ),
              ),
              SizedBox(height: 12.h),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) => CustomButton(
                  text: 'login'.tr(),
                  isLoading: state is LoginLoading,
                  onPressed: cubit.login,
                ),
              ),
              SizedBox(height: 12.h),
              CustomButton(
                text: 'continue_guest'.tr(),
                outlined: true,
                onPressed: () async {
                  await CacheHelper.removeData(key: CacheKeys.token);
                  await CacheHelper.removeData(key: CacheKeys.userName);
                  await CacheHelper.removeData(key: CacheKeys.userEmail);
                  await CacheHelper.removeData(key: CacheKeys.userRole);
                  await CacheHelper.removeData(key: CacheKeys.userAvatar);
                  await CacheHelper.saveData(key: CacheKeys.isGuest, value: true);
                  if (context.mounted) {
                    pushAndRemoveUntil(context, const MainLayout());
                  }
                },
              ),
              SizedBox(height: 14.h),
              Center(
                child: TextButton(
                  onPressed: () => push(context, const SignupView()),
                  child: Text.rich(
                    TextSpan(
                      text: 'no_account'.tr(),
                      style: AppStyles.regular14.copyWith(color: muted),
                      children: [
                        TextSpan(
                          text: 'sign_up'.tr(),
                          style: AppStyles.semiBold14
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Padding(
        padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
        child: Text(text, style: AppStyles.semiBold14.copyWith(color: color)),
      );
}
