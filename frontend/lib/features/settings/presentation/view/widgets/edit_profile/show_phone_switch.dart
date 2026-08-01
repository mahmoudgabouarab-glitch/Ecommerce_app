import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../view_model/edit_profile_cubit/edit_profile_cubit.dart';

class ShowPhoneSwitch extends StatelessWidget {
  const ShowPhoneSwitch({super.key, required this.cubit});
  final EditProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: SwitchListTile(
        value: cubit.showPhone,
        activeThumbColor: AppColors.primary,
        contentPadding: EdgeInsets.zero,
        title: Text('show_phone'.tr(), style: AppStyles.semiBold14),
        subtitle: Text('show_phone_desc'.tr(),
            style: AppStyles.regular12.copyWith(color: cs.onSurfaceVariant)),
        onChanged: cubit.setShowPhone,
      ),
    );
  }
}
