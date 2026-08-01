import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/theme_cubit.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/utils/spacing.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              _option(context, mode, ThemeMode.system, Icons.brightness_auto,
                  'system'.tr()),
              _option(context, mode, ThemeMode.light, Icons.light_mode_outlined,
                  'light'.tr()),
              _option(context, mode, ThemeMode.dark, Icons.dark_mode_outlined,
                  'dark'.tr()),
            ],
          ),
        );
      },
    );
  }

  Widget _option(BuildContext context, ThemeMode current, ThemeMode value,
      IconData icon, String label) {
    final cs = Theme.of(context).colorScheme;
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<ThemeCubit>().setMode(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: AppColors.brandGradient)
                : null,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22.r,
                  color: selected ? Colors.white : cs.onSurfaceVariant),
              spaceH(4),
              Text(label,
                  style: AppStyles.regular12.copyWith(
                    color: selected ? Colors.white : cs.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
