import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../view_model/signup/signup_cubit.dart';
import '../../verify_email_view.dart';
import 'signup_avatar_picker.dart';
import '../../../../../../core/utils/spacing.dart';

class SignupBody extends StatelessWidget {
  const SignupBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignupCubit>();
    final muted = AppStyles.muted(context);

    return BlocListener<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignupCodeSent) {
          push(context, VerifyEmailView(email: state.email));
        } else if (state is SignupFailure) {
          showSnackBar(context, state.error);
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        child: Form(
          key: cubit.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('create_account'.tr(), style: AppStyles.bold28),
              spaceH(8),
              Text('join_today'.tr(),
                  style: AppStyles.regular14.copyWith(color: muted)),
              spaceH(24),
              Center(
                child: BlocBuilder<SignupCubit, SignupState>(
                  buildWhen: (_, s) => s is SignupImagePicked,
                  builder: (context, _) => SignupAvatarPicker(
                      path: cubit.avatarPath, onTap: cubit.pickImage),
                ),
              ),
              spaceH(24),
              CustomTextField(
                controller: cubit.nameController,
                hint: 'full_name'.tr(),
                icon: Icons.person_outline,
              ),
              spaceH(16),
              CustomTextField(
                controller: cubit.emailController,
                hint: 'email'.tr(),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v != null && v.contains('@')) ? null : 'enter_valid_email'.tr(),
              ),
              spaceH(16),
              CustomTextField(
                controller: cubit.phoneController,
                hint: 'phone_optional'.tr(),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (_) => null,
              ),
              spaceH(16),
              CustomTextField(
                controller: cubit.passwordController,
                hint: 'password'.tr(),
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) => (v != null && v.length >= 6)
                    ? null
                    : 'password_min'.tr(),
              ),
              spaceH(16),
              CustomTextField(
                controller: cubit.confirmController,
                hint: 'confirm_password'.tr(),
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) => (v == cubit.passwordController.text)
                    ? null
                    : 'passwords_no_match'.tr(),
              ),
              spaceH(30),
              BlocBuilder<SignupCubit, SignupState>(
                builder: (context, state) => CustomButton(
                  text: 'sign_up'.tr(),
                  isLoading: state is SignupLoading,
                  onPressed: cubit.register,
                ),
              ),
              spaceH(16),
            ],
          ),
        ),
      ),
    );
  }
}
