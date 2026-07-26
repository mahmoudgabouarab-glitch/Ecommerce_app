import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppStyles {
  AppStyles._();

  static TextStyle get bold28 =>
      TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, height: 1.15);

  static TextStyle get bold24 =>
      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get bold20 =>
      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700);

  static TextStyle get semiBold16 =>
      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600);

  static TextStyle get semiBold14 =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600);

  static TextStyle get medium14 =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500);

  static TextStyle get regular14 =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, height: 1.4);

  static TextStyle get regular12 =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500);

  static TextStyle get price => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static Color muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
}
