import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/order_model.dart';
import '../../../../../../core/utils/spacing.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          _row(context, 'subtotal'.tr(), order.subtotal),
          if (order.discount > 0) ...[
            spaceH(6),
            _row(context, 'discount'.tr(), -order.discount,
                valueColor: AppColors.success),
          ],
          spaceH(6),
          _row(context, 'shipping'.tr(), order.shippingFee),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(color: cs.outlineVariant, height: 1),
          ),
          _row(context, 'total'.tr(), order.total, bold: true),
          spaceH(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('payment'.tr(),
                  style: AppStyles.regular14
                      .copyWith(color: cs.onSurfaceVariant)),
              Text(order.paymentMethod.toUpperCase(),
                  style: AppStyles.medium14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, double value,
      {bool bold = false, Color? valueColor}) {
    final cs = Theme.of(context).colorScheme;
    final prefix = value < 0 ? '- ' : '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? AppStyles.semiBold16
                : AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
        Text('$prefix${formatPrice(value.abs())}',
            style: bold
                ? AppStyles.bold20.copyWith(color: AppColors.primary)
                : AppStyles.medium14.copyWith(color: valueColor)),
      ],
    );
  }
}
