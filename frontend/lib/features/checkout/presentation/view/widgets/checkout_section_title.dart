import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/utils/spacing.dart';

class CheckoutSectionTitle extends StatelessWidget {
  const CheckoutSectionTitle({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppColors.primary),
        spaceW(8),
        Text(text, style: AppStyles.semiBold16),
      ],
    );
  }
}
