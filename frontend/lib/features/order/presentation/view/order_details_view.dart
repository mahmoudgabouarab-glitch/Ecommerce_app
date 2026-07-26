import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../cart/data/repo/cart_repo_impl.dart';
import '../../data/models/order_model.dart';
import '../../data/repo/order_repo_impl.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({super.key, required this.order});

  final OrderModel order;

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  bool _busy = false;
  late String _status = widget.order.status;

  OrderModel get order => widget.order;

  static const _steps = ['pending', 'processing', 'shipped', 'delivered'];

  Future<void> _reorder() async {
    setState(() => _busy = true);
    final repo = getIt<CartRepoImpl>();
    for (final item in order.items) {
      if (item.productId != null) {
        await repo.addToCart(productId: item.productId!, quantity: item.quantity);
      }
    }
    if (mounted) {
      setState(() => _busy = false);
      showSnackBar(context, 'added_all_cart'.tr(), success: true);
    }
  }

  Future<void> _cancel() async {
    setState(() => _busy = true);
    final result = await getIt<OrderRepoImpl>().cancelOrder(order.id);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (f) => showSnackBar(context, f.errorMessage),
      (_) {
        setState(() => _status = 'cancelled');
        showSnackBar(context, 'order_cancelled'.tr(), success: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cancelled = _status == 'cancelled';

    return Scaffold(
      appBar: AppBar(title: Text('order_no'.tr(args: ['${order.id}']))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            if (!cancelled)
              _Timeline(currentStatus: _status, steps: _steps)
            else
              _CancelledBanner(),
            SizedBox(height: 22.h),
            Text('items'.tr(), style: AppStyles.bold20),
            SizedBox(height: 12.h),
            ...order.items.map((item) => _OrderItemTile(item: item)),
            SizedBox(height: 12.h),
            Container(
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
                    SizedBox(height: 6.h),
                    _row(context, 'discount'.tr(), -order.discount,
                        valueColor: AppColors.success),
                  ],
                  SizedBox(height: 6.h),
                  _row(context, 'shipping'.tr(), order.shippingFee),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Divider(color: cs.outlineVariant, height: 1),
                  ),
                  _row(context, 'total'.tr(), order.total, bold: true),
                  SizedBox(height: 10.h),
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
            ),
            SizedBox(height: 20.h),
            CustomButton(
              text: 'reorder'.tr(),
              icon: Icons.replay_rounded,
              isLoading: _busy,
              onPressed: _busy ? null : _reorder,
            ),
            if (_status == 'pending') ...[
              SizedBox(height: 12.h),
              CustomButton(
                text: 'cancel_order'.tr(),
                outlined: true,
                onPressed: _busy ? null : _cancel,
              ),
            ],
          ],
        ),
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

class _Timeline extends StatelessWidget {
  const _Timeline({required this.currentStatus, required this.steps});
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
            SizedBox(height: 6.h),
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

class _CancelledBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel, color: AppColors.danger, size: 24.r),
          SizedBox(width: 12.w),
          Text('order_cancelled'.tr(),
              style: AppStyles.semiBold16.copyWith(color: AppColors.danger)),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});
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
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiBold14),
                SizedBox(height: 2.h),
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
