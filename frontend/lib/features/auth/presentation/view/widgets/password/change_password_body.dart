import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../view_model/password_cubit/password_cubit.dart';
import '../../../../../../core/utils/spacing.dart';

class ChangePasswordBody extends StatefulWidget {
  const ChangePasswordBody({super.key});

  @override
  State<ChangePasswordBody> createState() => _ChangePasswordBodyState();
}

class _ChangePasswordBodyState extends State<ChangePasswordBody> {
  final _currentController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordCubit, PasswordState>(
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
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spaceH(12),
              CustomTextField(
                controller: _currentController,
                hint: 'current_password'.tr(),
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              spaceH(16),
              CustomTextField(
                controller: _passController,
                hint: 'new_password'.tr(),
                icon: Icons.lock_reset_outlined,
                isPassword: true,
                validator: (v) =>
                    (v != null && v.length >= 6) ? null : 'password_min'.tr(),
              ),
              spaceH(28),
              CustomButton(
                text: 'save_changes'.tr(),
                isLoading: state is PasswordLoading,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  context.read<PasswordCubit>().change(
                        currentPassword: _currentController.text,
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
