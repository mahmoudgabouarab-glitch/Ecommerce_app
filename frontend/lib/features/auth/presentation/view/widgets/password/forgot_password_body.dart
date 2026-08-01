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
import '../../../view_model/password_cubit/password_cubit.dart';
import '../../reset_password_view.dart';
import '../../../../../../core/utils/spacing.dart';

class ForgotPasswordBody extends StatefulWidget {
  const ForgotPasswordBody({super.key});

  @override
  State<ForgotPasswordBody> createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<ForgotPasswordBody> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordCubit, PasswordState>(
      listener: (context, state) {
        if (state is ForgotSuccess) {
          push(
            context,
            ResetPasswordView(email: _emailController.text.trim()),
          );
        } else if (state is PasswordFailure) {
          showSnackBar(context, state.error);
        }
      },
      builder: (context, state) => SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            spaceH(20),
            Icon(Icons.lock_reset_rounded,
                color: AppColors.primary, size: 56.r),
            spaceH(20),
            Text('reset_password'.tr(), style: AppStyles.bold24),
            spaceH(8),
            Text('forgot_subtitle'.tr(),
                style: AppStyles.regular14
                    .copyWith(color: AppStyles.muted(context))),
            spaceH(28),
            CustomTextField(
              controller: _emailController,
              hint: 'email'.tr(),
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            spaceH(28),
            CustomButton(
              text: 'send_code'.tr(),
              isLoading: state is PasswordLoading,
              onPressed: () => context
                  .read<PasswordCubit>()
                  .forgot(_emailController.text.trim()),
            ),
          ],
        ),
      ),
    );
  }
}
