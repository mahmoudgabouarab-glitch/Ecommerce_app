import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../view_model/edit_profile_cubit/edit_profile_cubit.dart';
import '../../../../../../core/utils/spacing.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({super.key, required this.cubit});
  final EditProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    const options = {'male': Icons.male, 'female': Icons.female};
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: options.entries.map((e) {
        final selected = cubit.gender == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => cubit.setGender(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: AppColors.brandGradient)
                    : null,
                color: selected ? null : cs.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: selected ? Colors.transparent : cs.outline),
              ),
              child: Column(
                children: [
                  Icon(e.value,
                      color: selected ? Colors.white : cs.onSurfaceVariant,
                      size: 22.r),
                  spaceH(4),
                  Text(e.key.tr(),
                      style: AppStyles.regular12.copyWith(
                          color:
                              selected ? Colors.white : cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
