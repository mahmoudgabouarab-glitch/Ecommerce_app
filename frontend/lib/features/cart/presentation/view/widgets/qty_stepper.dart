import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/styles.dart';

class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.quantity,
    required this.canDecrement,
    required this.onMinus,
    required this.onPlus,
  });
  final int quantity;
  final bool canDecrement;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          _btn(context, Icons.remove, canDecrement ? onMinus : null),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text('$quantity', style: AppStyles.semiBold14),
          ),
          _btn(context, Icons.add, onPlus),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, IconData icon, VoidCallback? onTap) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Icon(icon,
            size: 18.r,
            color: onTap == null
                ? cs.onSurfaceVariant.withValues(alpha: 0.35)
                : AppColors.primary),
      ),
    );
  }
}
