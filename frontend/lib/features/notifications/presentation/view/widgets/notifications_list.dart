import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/skeletons.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../view_model/notifications_cubit/notifications_cubit.dart';
import 'notification_tile.dart';
import '../../../../../core/utils/spacing.dart';

class NotificationsList extends StatelessWidget {
  const NotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        if (state is NotificationsLoading || state is NotificationsInitial) {
          return const ListRowsShimmer(rowHeight: 84);
        }
        if (state is NotificationsFailure) {
          return ErrorState(message: state.error, onRetry: cubit.load);
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
          separatorBuilder: (_, _) => spaceH(10),
          itemBuilder: (context, i) => NotificationTile(item: items[i]),
        );
      },
    );
  }
}
