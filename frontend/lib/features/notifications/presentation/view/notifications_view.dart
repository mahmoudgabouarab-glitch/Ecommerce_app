import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/view/widgets/login_required.dart';
import '../../../order/data/repo/order_repo_impl.dart';
import '../../../order/presentation/view/orders_view.dart';
import '../../../order/presentation/view_model/orders_cubit/orders_cubit.dart';
import '../../data/models/notification_model.dart';
import '../view_model/notifications_cubit/notifications_cubit.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr()),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final hasUnread = cubit.unreadCount > 0;
              return TextButton(
                onPressed: hasUnread ? cubit.markAllRead : null,
                child: Text('mark_all_read'.tr(),
                    style: AppStyles.semiBold14.copyWith(
                        color: hasUnread
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant)),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: !isLoggedInUser()
            ? GuestState(
                icon: Icons.notifications_outlined, title: 'notifications'.tr())
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: cubit.load,
                child: BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    if (state is NotificationsLoading ||
                        state is NotificationsInitial) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary));
                    }
                    if (state is NotificationsFailure) {
                      return ErrorState(
                          message: state.error, onRetry: cubit.load);
                    }
                    final items = (state as NotificationsLoaded).items;
                    if (items.isEmpty) {
                      return EmptyState(
                        icon: Icons.notifications_off_outlined,
                        title: 'no_notifications'.tr(),
                        subtitle: 'no_notifications_hint'.tr(),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => SizedBox(height: 10.h),
                      itemBuilder: (context, i) =>
                          _NotificationTile(item: items[i]),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});
  final NotificationModel item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final unread = !item.isRead;
    return GestureDetector(
      onTap: () {
        context.read<NotificationsCubit>().markRead(item.id);
        if (item.orderId != null) {
          push(
            context,
            BlocProvider(
              create: (_) =>
                  OrdersCubit(getIt<OrderRepoImpl>())..getOrders(),
              child: const OrdersView(),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: unread
              ? AppColors.primary.withValues(alpha: 0.06)
              : cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: unread
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : cs.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                item.type == 'order'
                    ? Icons.local_shipping_outlined
                    : Icons.notifications_outlined,
                color: AppColors.primary,
                size: 21.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
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
                  Text(item.body,
                      style: AppStyles.regular12
                          .copyWith(color: cs.onSurfaceVariant, height: 1.4)),
                  SizedBox(height: 6.h),
                  Text(_relativeTime(context, item.createdAt),
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

  String _relativeTime(BuildContext context, DateTime? time) {
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
