import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../../../main_layout.dart';
import '../../../view_model/signup/signup_cubit.dart';

class SignupBody extends StatelessWidget {
  const SignupBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignupCubit>();
    final muted = AppStyles.muted(context);

    return BlocListener<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          pushAndRemoveUntil(context, const MainLayout());
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
              SizedBox(height: 8.h),
              Text('join_today'.tr(),
                  style: AppStyles.regular14.copyWith(color: muted)),
              SizedBox(height: 24.h),
              Center(
                child: BlocBuilder<SignupCubit, SignupState>(
                  buildWhen: (_, s) => s is SignupImagePicked,
                  builder: (context, _) =>
                      _AvatarPicker(path: cubit.avatarPath, onTap: cubit.pickImage),
                ),
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                controller: cubit.nameController,
                hint: 'full_name'.tr(),
                icon: Icons.person_outline,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: cubit.emailController,
                hint: 'email'.tr(),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v != null && v.contains('@')) ? null : 'enter_valid_email'.tr(),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: cubit.phoneController,
                hint: 'phone_optional'.tr(),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (_) => null,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: cubit.passwordController,
                hint: 'password'.tr(),
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) => (v != null && v.length >= 6)
                    ? null
                    : 'password_min'.tr(),
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: cubit.confirmController,
                hint: 'confirm_password'.tr(),
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) => (v == cubit.passwordController.text)
                    ? null
                    : 'passwords_no_match'.tr(),
              ),
              SizedBox(height: 30.h),
              BlocBuilder<SignupCubit, SignupState>(
                builder: (context, state) => CustomButton(
                  text: 'sign_up'.tr(),
                  isLoading: state is SignupLoading,
                  onPressed: cubit.register,
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular avatar picker for the signup form.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.path, required this.onTap});
  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 100.r,
            height: 100.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: AppColors.brandGradient),
            ),
            padding: EdgeInsets.all(3.r),
            child: ClipOval(
              child: path != null
                  ? Image.file(File(path!), fit: BoxFit.cover)
                  : Container(
                      color: cs.surfaceContainerHigh,
                      alignment: Alignment.center,
                      child: Icon(Icons.person_outline,
                          size: 44.r, color: cs.onSurfaceVariant),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor, width: 2),
              ),
              child: Icon(Icons.add_a_photo_outlined,
                  color: Colors.white, size: 15.r),
            ),
          ),
        ],
      ),
    );
  }
}
