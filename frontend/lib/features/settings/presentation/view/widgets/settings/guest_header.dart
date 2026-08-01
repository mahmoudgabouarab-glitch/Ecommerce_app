import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../auth/presentation/view/login_view.dart';
import '../../../../../../core/utils/spacing.dart';

class GuestHeader extends StatelessWidget {
  const GuestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.brandGradient),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Icon(Icons.person_outline, color: Colors.white, size: 30.r),
          ),
          spaceW(16),
          Expanded(
            child: Text('login_required_msg'.tr(),
                style: AppStyles.semiBold16.copyWith(color: Colors.white)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            onPressed: () => pushAndRemoveUntil(context, const LoginView()),
            child: Text('login_now'.tr()),
          ),
        ],
      ),
    );
  }
}
