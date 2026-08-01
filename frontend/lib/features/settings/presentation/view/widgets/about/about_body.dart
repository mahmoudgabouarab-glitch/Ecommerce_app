import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import 'about_feature.dart';
import '../../../../../../core/utils/spacing.dart';

class AboutBody extends StatelessWidget {
  const AboutBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        spaceH(20),
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
        spaceH(20),
        Center(child: Text('app_name'.tr(), style: AppStyles.bold28)),
        spaceH(6),
        Center(
          child: Text('${'version'.tr()} 1.0.0',
              style: AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
        ),
        spaceH(24),
        Text('about_desc'.tr(),
            textAlign: TextAlign.center,
            style: AppStyles.regular14
                .copyWith(color: cs.onSurfaceVariant, height: 1.7)),
        spaceH(30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AboutFeature(icon: Icons.storefront_outlined, label: 'feat_shop'.tr()),
            AboutFeature(
                icon: Icons.verified_user_outlined, label: 'feat_secure'.tr()),
            AboutFeature(
                icon: Icons.local_shipping_outlined, label: 'feat_fast'.tr()),
          ],
        ),
        spaceH(40),
        Center(
          child: Text('made_with'.tr(),
              style: AppStyles.regular12.copyWith(color: cs.onSurfaceVariant)),
        ),
        spaceH(6),
        Center(
          child: Text('© 2026 Bazar · ${'rights_reserved'.tr()}',
              style: AppStyles.regular12.copyWith(color: cs.onSurfaceVariant)),
        ),
      ],
    );
  }
}
