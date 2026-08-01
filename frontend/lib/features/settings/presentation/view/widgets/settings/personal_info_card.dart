import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/network/cache_helper.dart';
import '../../../../../../core/network/cache_keys.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/utils/spacing.dart';

class PersonalInfoCard extends StatelessWidget {
  const PersonalInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String? val(String key) {
      final v = CacheHelper.getDataString(key: key);
      return (v == null || v.isEmpty) ? null : v;
    }

    final phone = val(CacheKeys.userPhone);
    final gender = val(CacheKeys.userGender);
    final birth = val(CacheKeys.userBirthDate);
    final bio = val(CacheKeys.userBio);

    if (phone == null && gender == null && birth == null && bio == null) {
      return const SizedBox.shrink();
    }

    final rows = <Widget>[
      if (phone != null) _row(context, Icons.phone_outlined, 'phone'.tr(), phone),
      if (gender != null)
        _row(context, Icons.wc_outlined, 'gender'.tr(), gender.tr()),
      if (birth != null)
        _row(context, Icons.cake_outlined, 'birth_date'.tr(), birth),
      if (bio != null) _row(context, Icons.info_outline, 'bio'.tr(), bio),
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('personal_info'.tr(), style: AppStyles.semiBold16),
          spaceH(4),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.r, color: AppColors.primary),
          spaceW(12),
          Text('$label:  ',
              style: AppStyles.medium14.copyWith(color: cs.onSurfaceVariant)),
          Expanded(
            child: Text(value, style: AppStyles.medium14),
          ),
        ],
      ),
    );
  }
}
