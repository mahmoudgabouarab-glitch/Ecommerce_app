import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../../data/models/admin_user_model.dart';
import '../../view_model/admin_users_cubit/admin_users_cubit.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<AdminUsersCubit>().getUsers(search: value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: TextField(
            controller: _search,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'search_users'.tr(),
              prefixIcon:
                  Icon(Icons.search, color: cs.onSurfaceVariant, size: 21.r),
              suffixIcon: ValueListenableBuilder(
                valueListenable: _search,
                builder: (_, value, _) => value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: Icon(Icons.close,
                            color: cs.onSurfaceVariant, size: 20.r),
                        onPressed: () {
                          _search.clear();
                          context.read<AdminUsersCubit>().getUsers();
                        },
                      ),
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocConsumer<AdminUsersCubit, AdminUsersState>(
            listener: (context, state) {
              if (state is AdminUsersFailure) showSnackBar(context, state.error);
            },
            builder: (context, state) {
              if (state is AdminUsersLoading || state is AdminUsersInitial) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              final users = state is AdminUsersLoaded
                  ? state.users
                  : <AdminUserModel>[];
              final updatingId =
                  state is AdminUsersLoaded ? state.updatingId : null;
              if (users.isEmpty) {
                return EmptyState(
                    icon: Icons.people_outline, title: 'no_users'.tr());
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                itemCount: users.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, i) => _UserTile(
                  user: users[i],
                  isUpdating: updatingId == users[i].id,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.isUpdating});
  final AdminUserModel user;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
                ? NetworkImage(user.avatar!)
                : null,
            child: (user.avatar == null || user.avatar!.isEmpty)
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: AppStyles.semiBold14
                        .copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(user.name,
                          style: AppStyles.semiBold14,
                          overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 8.w),
                    _RoleChip(isAdmin: user.isAdmin),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(user.email,
                    style: AppStyles.regular12
                        .copyWith(color: cs.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (isUpdating)
            SizedBox(
              width: 22.r,
              height: 22.r,
              child: const CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            )
          else
            _RoleButton(user: user),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({required this.user});
  final AdminUserModel user;

  @override
  Widget build(BuildContext context) {
    final makeCustomer = user.isAdmin;
    final color = makeCustomer ? AppColors.danger : AppColors.primary;
    return TextButton.icon(
      onPressed: () => _confirm(context),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(
          makeCustomer
              ? Icons.remove_moderator_outlined
              : Icons.admin_panel_settings_outlined,
          size: 18.r),
      label: Text(makeCustomer ? 'remove_admin'.tr() : 'make_admin'.tr(),
          style: AppStyles.semiBold14.copyWith(color: color, fontSize: 12.sp)),
    );
  }

  void _confirm(BuildContext context) {
    final cubit = context.read<AdminUsersCubit>();
    final makeCustomer = user.isAdmin;
    final role = makeCustomer ? 'customer' : 'admin';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(makeCustomer ? 'remove_admin_q'.tr() : 'make_admin_q'.tr()),
        content: Text(
          (makeCustomer ? 'remove_admin_desc'.tr() : 'make_admin_desc'.tr())
              .replaceFirst('{}', user.name),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              cubit.setRole(user, role);
              Navigator.pop(context);
            },
            child: Text('confirm'.tr(),
                style: TextStyle(
                    color: makeCustomer ? AppColors.danger : AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.isAdmin});
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final color = isAdmin ? AppColors.primary : Theme.of(context).colorScheme.outline;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(isAdmin ? 'admin_role'.tr() : 'customer_role'.tr(),
          style: AppStyles.regular12.copyWith(color: color)),
    );
  }
}
