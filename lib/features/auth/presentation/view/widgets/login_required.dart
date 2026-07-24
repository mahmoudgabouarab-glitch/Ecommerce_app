import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../login_view.dart';

/// Dialog shown when a guest tries a protected action.
Future<void> showLoginRequired(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text('login_required'.tr(), style: AppStyles.bold20),
      content: Text('login_required_msg'.tr(),
          style: AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('cancel'.tr(),
              style: TextStyle(color: cs.onSurfaceVariant)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            Navigator.pop(dialogContext);
            pushAndRemoveUntil(context, const LoginView());
          },
          child: Text('login_now'.tr()),
        ),
      ],
    ),
  );
}

/// A full-screen placeholder for guest users on protected tabs (cart/orders).
class GuestState extends StatelessWidget {
  const GuestState({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(22.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44.r, color: AppColors.primary),
            ),
            SizedBox(height: 18.h),
            Text(title, style: AppStyles.bold20, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text('login_required_msg'.tr(),
                textAlign: TextAlign.center,
                style: AppStyles.regular14
                    .copyWith(color: cs.onSurfaceVariant)),
            SizedBox(height: 20.h),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              onPressed: () => pushAndRemoveUntil(context, const LoginView()),
              child: Text('login_now'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
