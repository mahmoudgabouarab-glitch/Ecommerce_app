import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../cart/data/repo/cart_repo_impl.dart';
import '../../data/models/order_model.dart';
import '../../data/repo/order_repo_impl.dart';
import 'widgets/order_details/cancelled_banner.dart';
import 'widgets/order_details/order_item_tile.dart';
import 'widgets/order_details/order_summary_card.dart';
import 'widgets/order_details/order_timeline.dart';
import '../../../../core/utils/spacing.dart';

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
    final cancelled = _status == 'cancelled';

    return Scaffold(
      appBar: AppBar(title: Text('order_no'.tr(args: ['${order.id}']))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            if (!cancelled)
              OrderTimeline(currentStatus: _status, steps: _steps)
            else
              const CancelledBanner(),
            spaceH(22),
            Text('items'.tr(), style: AppStyles.bold20),
            spaceH(12),
            ...order.items.map((item) => OrderItemTile(item: item)),
            spaceH(12),
            OrderSummaryCard(order: order),
            spaceH(20),
            CustomButton(
              text: 'reorder'.tr(),
              icon: Icons.replay_rounded,
              isLoading: _busy,
              onPressed: _busy ? null : _reorder,
            ),
            if (_status == 'pending') ...[
              spaceH(12),
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
}
