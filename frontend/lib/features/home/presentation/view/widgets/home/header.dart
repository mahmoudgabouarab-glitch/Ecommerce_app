import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../genie/presentation/view/genie_view.dart';
import '../../../../../notifications/presentation/view/notifications_view.dart';
import '../../../../../notifications/presentation/view_model/notifications_cubit/notifications_cubit.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'hello'.tr(args: [name]),
                style: AppStyles.regular14.copyWith(color: cs.onSurfaceVariant),
              ),
              SizedBox(height: 2.h),
              Text('find_favorite'.tr(), style: AppStyles.bold24),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        const _GenieButton(),
        SizedBox(width: 10.w),
        const _NotificationBell(),
      ],
    );
  }
}

class _GenieButton extends StatelessWidget {
  const _GenieButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => push(context, const GenieView()),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFFB347)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.auto_awesome, color: Colors.white, size: 24.r),
      ),
    );
  }
}
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => push(context, const NotificationsView()),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: cs.outline),
        ),
        alignment: Alignment.center,
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, _) {
            final count = context.read<NotificationsCubit>().unreadCount;
            return Badge(
              isLabelVisible: count > 0,
              backgroundColor: AppColors.danger,
              label: Text(count > 99 ? '99+' : '$count'),
              offset: Offset(6.w, -6.h),
              child: Icon(
                Icons.notifications_outlined,
                color: cs.onSurface,
                size: 24.r,
              ),
            );
          },
        ),
      ),
    );
  }
}
