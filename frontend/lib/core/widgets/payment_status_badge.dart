import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import '../utils/styles.dart';

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon, String key) = switch (status) {
      'paid' => (AppColors.success, Icons.check_circle, 'pay_paid'),
      'failed' => (AppColors.danger, Icons.cancel, 'pay_failed'),
      'refunded' => (AppColors.info, Icons.undo, 'pay_refunded'),
      _ => (AppColors.warning, Icons.schedule, 'pay_unpaid'),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.r, color: color),
          SizedBox(width: 4.w),
          Text(
            key.tr(),
            style: AppStyles.regular12.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
