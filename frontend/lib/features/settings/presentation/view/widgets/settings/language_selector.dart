import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = context.locale.languageCode;

    Widget option(String code, String label) {
      final selected = current == code;
      return Expanded(
        child: GestureDetector(
          onTap: () => context.setLocale(Locale(code)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(colors: AppColors.brandGradient)
                  : null,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: AppStyles.semiBold14.copyWith(
                  color: selected ? Colors.white : cs.onSurfaceVariant,
                )),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          option('en', 'English'),
          option('ar', 'العربية'),
        ],
      ),
    );
  }
}
