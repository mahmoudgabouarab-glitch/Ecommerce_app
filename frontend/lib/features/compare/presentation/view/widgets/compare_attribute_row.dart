import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/styles.dart';
import '../../../../../core/utils/spacing.dart';

class CompareAttributeRow extends StatelessWidget {
  const CompareAttributeRow({
    super.key,
    required this.label,
    required this.cells,
    this.alt = false,
  });

  final String label;
  final List<Widget> cells;
  final bool alt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: alt ? cs.surfaceContainerLow : null,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppStyles.regular12.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 0.6,
              fontSize: 10.sp,
            ),
          ),
          spaceH(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cells
                .map((c) => Expanded(child: Center(child: c)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
