import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/utils/spacing.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({
    super.key,
    required this.currentStatus,
    required this.steps,
  });
  final String currentStatus;
  final List<String> steps;

  static const _labels = {
    'pending': 'step_placed',
    'processing': 'step_processing',
    'shipped': 'step_shipped',
    'delivered': 'step_delivered',
  };
  static const _icons = {
    'pending': Icons.receipt_long,
    'processing': Icons.inventory_2_outlined,
    'shipped': Icons.local_shipping_outlined,
    'delivered': Icons.check_circle_outline,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentIndex = steps.indexOf(currentStatus).clamp(0, steps.length - 1);

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final done = (i ~/ 2) < currentIndex;
          return Expanded(
            child: Container(
              height: 3.h,
              margin: EdgeInsets.only(bottom: 22.h),
              color: done ? AppColors.primary : cs.outlineVariant,
            ),
          );
        }
        final index = i ~/ 2;
        final step = steps[index];
        final reached = index <= currentIndex;
        return Column(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                gradient: reached
                    ? const LinearGradient(colors: AppColors.brandGradient)
                    : null,
                color: reached ? null : cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(_icons[step],
                  size: 20.r,
                  color: reached ? Colors.white : cs.onSurfaceVariant),
            ),
            spaceH(6),
            SizedBox(
              width: 64.w,
              child: Text(_labels[step]!.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyles.regular12.copyWith(
                    color: reached ? cs.onSurface : cs.onSurfaceVariant,
                  )),
            ),
          ],
        );
      }),
    );
  }
}
