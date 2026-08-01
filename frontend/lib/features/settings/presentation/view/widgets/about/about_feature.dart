import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/utils/spacing.dart';

class AboutFeature extends StatelessWidget {
  const AboutFeature({super.key, required this.icon, required this.label});
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
        spaceH(8),
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
