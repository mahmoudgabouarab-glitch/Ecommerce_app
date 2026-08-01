import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/utils/spacing.dart';

class CancelledBanner extends StatelessWidget {
  const CancelledBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel, color: AppColors.danger, size: 24.r),
          spaceW(12),
          Text('order_cancelled'.tr(),
              style: AppStyles.semiBold16.copyWith(color: AppColors.danger)),
        ],
      ),
    );
  }
}
