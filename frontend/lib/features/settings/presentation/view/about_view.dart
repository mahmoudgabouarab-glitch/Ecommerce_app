import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/styles.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('about'.tr())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            SizedBox(height: 20.h),
            Center(
              child: Container(
                padding: EdgeInsets.all(22.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.brandGradient),
                  borderRadius: BorderRadius.circular(26.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(Icons.shopping_bag_rounded,
                    color: Colors.white, size: 52.r),
              ),
            ),
            SizedBox(height: 20.h),
            Center(child: Text('app_name'.tr(), style: AppStyles.bold28)),
            SizedBox(height: 6.h),
            Center(
              child: Text('${'version'.tr()} 1.0.0',
                  style: AppStyles.regular14
                      .copyWith(color: cs.onSurfaceVariant)),
            ),
            SizedBox(height: 24.h),
            Text('about_desc'.tr(),
                textAlign: TextAlign.center,
                style: AppStyles.regular14
                    .copyWith(color: cs.onSurfaceVariant, height: 1.7)),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Feature(icon: Icons.storefront_outlined, label: 'feat_shop'.tr()),
                _Feature(icon: Icons.verified_user_outlined, label: 'feat_secure'.tr()),
                _Feature(icon: Icons.local_shipping_outlined, label: 'feat_fast'.tr()),
              ],
            ),
            SizedBox(height: 40.h),
            Center(
              child: Text('made_with'.tr(),
                  style: AppStyles.regular12
                      .copyWith(color: cs.onSurfaceVariant)),
            ),
            SizedBox(height: 6.h),
            Center(
              child: Text('© 2026 ShopSphere · ${'rights_reserved'.tr()}',
                  style: AppStyles.regular12
                      .copyWith(color: cs.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 26.r),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 80.w,
          child: Text(label,
              textAlign: TextAlign.center,
              style: AppStyles.regular12.copyWith(color: cs.onSurface)),
        ),
      ],
    );
  }
}
