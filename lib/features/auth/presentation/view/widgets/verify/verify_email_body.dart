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
import '../../../view_model/verify_email/verify_email_cubit.dart';

class VerifyEmailBody extends StatelessWidget {
  const VerifyEmailBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VerifyEmailCubit>();
    final muted = AppStyles.muted(context);

    return BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
      listener: (context, state) {
        if (state is VerifyEmailSuccess) {
          pushAndRemoveUntil(context, const MainLayout());
        } else if (state is VerifyEmailResent) {
          showSnackBar(context, 'code_sent'.tr(), success: true);
        } else if (state is VerifyEmailFailure) {
          showSnackBar(context, state.error);
        }
      },
      builder: (context, state) => SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Icon(Icons.mark_email_read_outlined,
                color: AppColors.primary, size: 56.r),
            SizedBox(height: 20.h),
            Text('verify_email'.tr(), style: AppStyles.bold24),
            SizedBox(height: 8.h),
            Text('verify_email_subtitle'.tr(args: [cubit.email]),
                style: AppStyles.regular14.copyWith(color: muted)),
            SizedBox(height: 28.h),
            CustomTextField(
              controller: cubit.codeController,
              hint: 'verification_code'.tr(),
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'verify'.tr(),
              isLoading: state is VerifyEmailLoading,
              onPressed: cubit.verify,
            ),
            SizedBox(height: 8.h),
            Center(
              child: TextButton(
                onPressed: cubit.resend,
                child: Text('resend_code'.tr(),
                    style: AppStyles.semiBold14
                        .copyWith(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
