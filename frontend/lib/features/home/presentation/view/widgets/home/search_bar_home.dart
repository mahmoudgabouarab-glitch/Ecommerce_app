import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_functions.dart';
import '../../search_view.dart';
import '../../../../../../core/utils/spacing.dart';

class SearchBarHome extends StatelessWidget {
  const SearchBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => push(context, const SearchView()),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: cs.onSurfaceVariant),
            spaceW(10),
            Text(
              'search_products'.tr(),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15.sp),
            ),
          ],
        ),
      ),
    );
  }
}
