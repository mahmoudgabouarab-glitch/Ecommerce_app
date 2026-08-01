import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../view_model/edit_profile_cubit/edit_profile_cubit.dart';
import '../../../../../../core/utils/spacing.dart';

class BirthDateField extends StatelessWidget {
  const BirthDateField({super.key, required this.cubit});
  final EditProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = cubit.birthDate;

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final initial = value != null
            ? DateTime.tryParse(value) ?? DateTime(now.year - 20)
            : DateTime(now.year - 20);
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1940),
          lastDate: now,
        );
        if (picked != null) cubit.setBirthDate(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: cs.onSurfaceVariant, size: 21.r),
            spaceW(12),
            Text(
              value ?? 'select_date'.tr(),
              style: AppStyles.medium14.copyWith(
                color: value != null ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
