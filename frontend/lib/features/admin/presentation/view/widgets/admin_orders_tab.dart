import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/network/service_locator.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/payment_status_badge.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../../../order/data/models/order_model.dart';
import '../../../data/repo/admin_repo_impl.dart';
import '../../view_model/admin_orders_cubit/admin_orders_cubit.dart';

const _statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];

class AdminOrdersTab extends StatelessWidget {
  const AdminOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminOrdersCubit(getIt<AdminRepoImpl>())..getOrders(),
      child: BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
        builder: (context, state) {
          if (state is AdminOrdersLoading || state is AdminOrdersInitial) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is AdminOrdersFailure) {
            return ErrorState(
              message: state.error,
              onRetry: () => context.read<AdminOrdersCubit>().getOrders(),
            );
          }
          final orders = (state as AdminOrdersLoaded).orders;
          if (orders.isEmpty) {
            return EmptyState(
                icon: Icons.receipt_long_outlined, title: 'no_orders'.tr());
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: orders.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, i) => _AdminOrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

Color _statusColor(String status) => switch (status) {
      'delivered' => AppColors.success,
      'cancelled' => AppColors.danger,
      'shipped' => AppColors.info,
      'processing' => AppColors.primary,
      _ => AppColors.warning,
    };

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _statusColor(order.status);

    return Container(
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
              Text('order_no'.tr(args: ['${order.id}']),
                  style: AppStyles.semiBold16),
              const Spacer(),
              Text(formatPrice(order.total),
                  style: AppStyles.semiBold16.copyWith(color: AppColors.primary)),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Text(
                    '${'items_count'.tr(args: ['${order.items.length}'])} • ${order.paymentMethod.toUpperCase()}',
                    style: AppStyles.regular12
                        .copyWith(color: cs.onSurfaceVariant)),
              ),
              if (order.paymentMethod == 'card')
                PaymentStatusBadge(status: order.paymentStatus),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text('status'.tr(),
                  style: AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
              SizedBox(width: 10.w),
              PopupMenuButton<String>(
                onSelected: (s) =>
                    context.read<AdminOrdersCubit>().updateStatus(order.id, s),
                itemBuilder: (_) => _statuses
                    .map((s) =>
                        PopupMenuItem(value: s, child: Text('status_$s'.tr())))
                    .toList(),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('status_${order.status}'.tr(),
                          style: AppStyles.semiBold14.copyWith(color: color)),
                      SizedBox(width: 4.w),
                      Icon(Icons.keyboard_arrow_down, color: color, size: 18.r),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
