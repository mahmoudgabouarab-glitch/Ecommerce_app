import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/styles.dart';
import '../../../auth/presentation/view/widgets/login_required.dart';
import '../view_model/notifications_cubit/notifications_cubit.dart';
import 'widgets/notifications_list.dart';

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
                child: const NotificationsList(),
              ),
      ),
    );
  }
}
