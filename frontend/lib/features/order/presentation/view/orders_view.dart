import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/payment_status_badge.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/view/widgets/login_required.dart';
import '../../data/models/order_model.dart';
import '../view_model/orders_cubit/orders_cubit.dart';
import 'order_details_view.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('my_orders'.tr())),
      body: SafeArea(
        child: !isLoggedInUser()
            ? GuestState(
                icon: Icons.receipt_long_outlined, title: 'my_orders'.tr())
            : BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading || state is OrdersInitial) {
              return const ListRowsShimmer(rowHeight: 110);
            }
            if (state is OrdersFailure) {
              return ErrorState(
                message: state.error,
                onRetry: () => context.read<OrdersCubit>().getOrders(),
              );
            }
            final orders = (state as OrdersSuccess).orders;
            if (orders.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'no_orders'.tr(),
                subtitle: 'orders_appear'.tr(),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: orders.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, i) => _OrderCard(order: orders[i]),
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
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
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('order_no'.tr(args: ['${order.id}']),
                        style: AppStyles.semiBold16),
                    SizedBox(height: 2.h),
                    Text('${'items_count'.tr(args: ['${order.items.length}'])} • ${order.paymentMethod.toUpperCase()}',
                        style: AppStyles.regular12
                            .copyWith(color: cs.onSurfaceVariant)),
                    if (order.paymentMethod == 'card' ||
                        order.paymentStatus != 'unpaid') ...[
                      SizedBox(height: 6.h),
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
              Text('total'.tr(), style: AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
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
