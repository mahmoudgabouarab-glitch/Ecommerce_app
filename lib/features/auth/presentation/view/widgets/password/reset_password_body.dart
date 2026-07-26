import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../view_model/password_cubit/password_cubit.dart';

class ResetPasswordBody extends StatefulWidget {
  const ResetPasswordBody({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordBody> createState() => _ResetPasswordBodyState();
}

class _ResetPasswordBodyState extends State<ResetPasswordBody> {
  final _otpController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordCubit, PasswordState>(
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
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              Text('reset_subtitle'.tr(),
                  style: AppStyles.regular14
                      .copyWith(color: AppStyles.muted(context))),
              SizedBox(height: 20.h),
              CustomTextField(
                controller: _otpController,
                hint: 'reset_code'.tr(),
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _passController,
                hint: 'new_password'.tr(),
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) =>
                    (v != null && v.length >= 6) ? null : 'password_min'.tr(),
              ),
              SizedBox(height: 28.h),
              CustomButton(
                text: 'reset_password'.tr(),
                isLoading: state is PasswordLoading,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  context.read<PasswordCubit>().reset(
                        email: widget.email,
                        otp: _otpController.text.trim(),
                        password: _passController.text,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
