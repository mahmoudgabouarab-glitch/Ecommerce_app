import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/order_model.dart';
import '../../../../../../core/utils/spacing.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item});
  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedNetworkImage(
              imageUrl: item.productImage ?? '',
              width: 56.w,
              height: 56.w,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                  color: cs.surfaceContainerHigh, width: 56.w, height: 56.w),
              errorWidget: (_, _, _) =>
                  Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
            ),
          ),
          spaceW(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiBold14),
                spaceH(2),
                Text('${item.quantity} × ${formatPrice(item.unitPrice)}',
                    style: AppStyles.regular12
                        .copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text(formatPrice(item.unitPrice * item.quantity),
              style: AppStyles.semiBold14.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
