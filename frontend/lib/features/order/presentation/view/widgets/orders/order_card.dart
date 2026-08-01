import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/payment_status_badge.dart';
import '../../../../data/models/order_model.dart';
import '../../order_details_view.dart';
import '../../../../../../core/utils/spacing.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});
  final OrderModel order;

  (Color, IconData) get _status => switch (order.status) {
        'delivered' => (AppColors.success, Icons.check_circle),
        'cancelled' => (AppColors.danger, Icons.cancel),
        'shipped' => (AppColors.info, Icons.local_shipping),
        'processing' => (AppColors.primary, Icons.autorenew),
        _ => (AppColors.warning, Icons.schedule),
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (color, icon) = _status;

    return GestureDetector(
      onTap: () => push(context, OrderDetailsView(order: order)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(9.r),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 20.r),
                ),
                spaceW(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('order_no'.tr(args: ['${order.id}']),
                          style: AppStyles.semiBold16),
                      spaceH(2),
                      Text(
                          '${'items_count'.tr(args: ['${order.items.length}'])} • ${order.paymentMethod.toUpperCase()}',
                          style: AppStyles.regular12
                              .copyWith(color: cs.onSurfaceVariant)),
                      if (order.paymentMethod == 'card' ||
                          order.paymentStatus != 'unpaid') ...[
                        spaceH(6),
                        PaymentStatusBadge(status: order.paymentStatus),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(order.status,
                      style: AppStyles.regular12.copyWith(color: color)),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Divider(color: cs.outlineVariant, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('total'.tr(),
                    style: AppStyles.regular14
                        .copyWith(color: cs.onSurfaceVariant)),
                Text(formatPrice(order.total),
                    style: AppStyles.bold20.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
