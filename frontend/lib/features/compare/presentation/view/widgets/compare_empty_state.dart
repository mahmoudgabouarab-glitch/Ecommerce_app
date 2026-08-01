import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/styles.dart';
import '../../../../../core/utils/spacing.dart';

class CompareEmptyState extends StatelessWidget {
  const CompareEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.compare_arrows_rounded,
              size: 64.r, color: cs.onSurfaceVariant),
          spaceH(12),
          Text('compare_empty'.tr(),
              textAlign: TextAlign.center,
              style: AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
