import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/network/service_locator.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../home/presentation/view/details_view.dart';
import '../../../../order/data/repo/order_repo_impl.dart';
import '../../../../order/presentation/view/orders_view.dart';
import '../../../../order/presentation/view_model/orders_cubit/orders_cubit.dart';
import '../../../data/models/notification_model.dart';
import '../../view_model/notifications_cubit/notifications_cubit.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item});
  final NotificationModel item;

  static const _localizedKeys = {
    'order_placed',
    'order_confirmed',
    'order_processing',
    'order_shipped',
    'order_delivered',
    'order_cancelled',
    'order_pending',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final unread = !item.isRead;
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: unread ? AppColors.primary.withValues(alpha: 0.06) : cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: unread
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : cs.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 42.w,
              height: 42.w,
              child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                            color: AppColors.primary.withValues(alpha: 0.12)),
                        errorWidget: (_, _, _) => _fallbackIcon(),
                      ),
                    )
                  : _fallbackIcon(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(_title(),
                            style: unread
                                ? AppStyles.semiBold14
                                : AppStyles.medium14),
                      ),
                      if (unread)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          margin: EdgeInsets.only(left: 8.w, top: 4.h),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(_body(),
                      style: AppStyles.regular12
                          .copyWith(color: cs.onSurfaceVariant, height: 1.4)),
                  SizedBox(height: 6.h),
                  Text(_relativeTime(),
                      style: AppStyles.regular12
                          .copyWith(color: cs.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    context.read<NotificationsCubit>().markRead(item.id);
    if (item.orderId != null) {
      push(
        context,
        BlocProvider(
          create: (_) => OrdersCubit(getIt<OrderRepoImpl>())..getOrders(),
          child: const OrdersView(),
        ),
      );
    } else if (item.productId != null) {
      push(context, DetailsView(productId: item.productId!));
    }
  }

  Widget _fallbackIcon() => Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          switch (item.type) {
            'order' => Icons.local_shipping_outlined,
            'sale' => Icons.sell_outlined,
            _ => Icons.notifications_outlined,
          },
          color: AppColors.primary,
          size: 21.r,
        ),
      );

  String _title() {
    if (item.key != null && _localizedKeys.contains(item.key)) {
      return 'notif_${item.key}_title'.tr(args: ['${item.orderId ?? ''}']);
    }
    return item.title;
  }

  String _body() {
    if (item.key != null && _localizedKeys.contains(item.key)) {
      return 'notif_${item.key}_body'.tr(args: ['${item.orderId ?? ''}']);
    }
    return item.body;
  }

  String _relativeTime() {
    final time = item.createdAt;
    if (time == null) return '';
    final diff = DateTime.now().difference(time.toLocal());
    if (diff.inMinutes < 1) return 'just_now'.tr();
    if (diff.inMinutes < 60) return 'minutes_ago'.tr(args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return 'hours_ago'.tr(args: ['${diff.inHours}']);
    if (diff.inDays < 7) return 'days_ago'.tr(args: ['${diff.inDays}']);
    final d = time.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
