import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/skeletons.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../../../auth/presentation/view/widgets/login_required.dart';
import '../../../../checkout/presentation/view/checkout_view.dart';
import '../../../data/models/cart_model.dart';
import '../../view_model/cart_cubit/cart_cubit.dart';

class CartBody extends StatelessWidget {
  const CartBody({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isLoggedInUser()) {
      return GuestState(
          icon: Icons.shopping_cart_outlined, title: 'my_cart'.tr());
    }
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartActionError) showSnackBar(context, state.error);
      },
      builder: (context, state) {
        if (state is CartLoading || state is CartInitial) {
          return const ListRowsShimmer(rowHeight: 96);
        }
        if (state is CartFailure) {
          return ErrorState(
            message: state.error,
            onRetry: () => context.read<CartCubit>().getCart(),
          );
        }
        final cart =
            state is CartActionError ? state.cart : (state as CartSuccess).cart;
        if (cart.items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'cart_empty'.tr(),
            subtitle: 'browse_add'.tr(),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: cart.items.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, i) => _CartTile(item: cart.items[i]),
              ),
            ),
            _CheckoutBar(subtotal: cart.subtotal, count: cart.count),
          ],
        );
      },
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});
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
              placeholder: (_, _) =>
                  Container(color: cs.surfaceContainerHigh, width: 76.w, height: 76.w),
              errorWidget: (_, _, _) =>
                  Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
            ),
          ),
          SizedBox(width: 12.w),
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
                  SizedBox(height: 4.h),
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
                SizedBox(height: 6.h),
                Text(formatPrice(item.unitPrice), style: AppStyles.price),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _QtyStepper(
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

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
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

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.subtotal, required this.count});
  final double subtotal;
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  count == 1
                      ? 'subtotal_item'.tr()
                      : 'subtotal_items'.tr(args: ['$count']),
                  style: AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
              Text(formatPrice(subtotal), style: AppStyles.bold20),
            ],
          ),
          SizedBox(height: 14.h),
          CustomButton(
            text: 'proceed_checkout'.tr(),
            icon: Icons.arrow_forward_rounded,
            onPressed: () => push(context, CheckoutView(subtotal: subtotal)),
          ),
        ],
      ),
    );
  }
}
