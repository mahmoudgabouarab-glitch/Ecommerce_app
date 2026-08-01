import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../data/models/cart_model.dart';
import '../../view_model/cart_cubit/cart_cubit.dart';
import 'qty_stepper.dart';
import '../../../../../core/utils/spacing.dart';

class CartTile extends StatelessWidget {
  const CartTile({super.key, required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<CartCubit>();

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: item.product.image,
              width: 76.w,
              height: 76.w,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                  color: cs.surfaceContainerHigh, width: 76.w, height: 76.w),
              errorWidget: (_, _, _) =>
                  Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
            ),
          ),
          spaceW(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiBold14),
                if (item.variant != null &&
                    item.variant!.label.isNotEmpty) ...[
                  spaceH(4),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(item.variant!.label,
                          style: AppStyles.regular12
                              .copyWith(color: cs.onSurfaceVariant)),
                    ),
                  ),
                ],
                spaceH(6),
                Text(formatPrice(item.unitPrice), style: AppStyles.price),
                spaceH(8),
                Row(
                  children: [
                    QtyStepper(
                      quantity: item.quantity,
                      canDecrement: item.quantity > 1,
                      onMinus: () =>
                          cubit.updateQuantity(item.id, item.quantity - 1),
                      onPlus: () =>
                          cubit.updateQuantity(item.id, item.quantity + 1),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => cubit.removeItem(item.id),
                      icon: Icon(Icons.delete_outline,
                          color: AppColors.danger, size: 22.r),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
