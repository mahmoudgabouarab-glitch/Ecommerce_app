import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/network/cache_helper.dart';
import '../../../../../../core/network/cache_keys.dart';
import '../../../../../../core/network/service_locator.dart';
import '../../../../../../core/services/push_service.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../address/presentation/view/addresses_view.dart';
import '../../../../../admin/presentation/view/admin_dashboard_view.dart';
import '../../../../../auth/data/repo/auth_repo_impl.dart';
import '../../../../../auth/presentation/view/change_password_view.dart';
import '../../../../../auth/presentation/view/login_view.dart';
import '../../../../../notifications/presentation/view/notifications_view.dart';
import '../../../../../notifications/presentation/view_model/notifications_cubit/notifications_cubit.dart';
import '../../../../../wishlist/presentation/view/wishlist_view.dart';
import '../../about_view.dart';
import '../../edit_profile_view.dart';
import 'guest_header.dart';
import 'language_selector.dart';
import 'personal_info_card.dart';
import 'settings_header_card.dart';
import 'settings_tile.dart';
import 'theme_selector.dart';
import '../../../../../../core/utils/spacing.dart';

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  Future<void> _logout(BuildContext context) async {
    await PushService.unregister();
    await getIt<AuthRepoImpl>().logout();
    await CacheHelper.removeData(key: CacheKeys.token);
    await CacheHelper.removeData(key: CacheKeys.userName);
    await CacheHelper.removeData(key: CacheKeys.userEmail);
    await CacheHelper.removeData(key: CacheKeys.userAvatar);
    if (context.mounted) {
      context.read<NotificationsCubit>().reset();
      pushAndRemoveUntil(context, const LoginView());
    }
  }

  Future<void> _editProfile() async {
    final changed = await push<bool>(context, const EditProfileView());
    if (changed == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = CacheHelper.getDataString(key: CacheKeys.userName) ?? 'User';
    final email = CacheHelper.getDataString(key: CacheKeys.userEmail) ?? '';
    final avatar = CacheHelper.getDataString(key: CacheKeys.userAvatar);
    final isAdmin =
        CacheHelper.getDataString(key: CacheKeys.userRole) == 'admin';
    final loggedIn = isLoggedInUser();

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (loggedIn)
          SettingsHeaderCard(
            name: name,
            email: email,
            avatar: avatar,
            onEdit: _editProfile,
          )
        else
          const GuestHeader(),
        if (loggedIn) ...[
          spaceH(16),
          const PersonalInfoCard(),
        ],
        spaceH(12),
        Text('appearance'.tr(), style: AppStyles.semiBold16),
        spaceH(12),
        const ThemeSelector(),
        spaceH(22),
        Text('language'.tr(), style: AppStyles.semiBold16),
        spaceH(12),
        const LanguageSelector(),
        spaceH(22),
        if (loggedIn && isAdmin) ...[
          Text('admin'.tr(), style: AppStyles.semiBold16),
          spaceH(12),
          SettingsTile(
            icon: Icons.dashboard_outlined,
            title: 'admin_dashboard'.tr(),
            onTap: () => push(context, const AdminDashboardView()),
          ),
          spaceH(12),
        ],
        Text('account'.tr(), style: AppStyles.semiBold16),
        spaceH(12),
        if (loggedIn) ...[
          SettingsTile(
            icon: Icons.person_outline,
            title: 'edit_profile'.tr(),
            onTap: _editProfile,
          ),
          SettingsTile(
            icon: Icons.lock_outline,
            title: 'change_password'.tr(),
            onTap: () => push(context, const ChangePasswordView()),
          ),
          SettingsTile(
            icon: Icons.location_on_outlined,
            title: 'addresses'.tr(),
            onTap: () => push(context, const AddressesView()),
          ),
          SettingsTile(
            icon: Icons.favorite_outline,
            title: 'wishlist'.tr(),
            onTap: () => push(context, const WishlistView()),
          ),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, _) => SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'notifications'.tr(),
              badgeCount: context.read<NotificationsCubit>().unreadCount,
              onTap: () => push(context, const NotificationsView()),
            ),
          ),
        ],
        SettingsTile(
          icon: Icons.info_outline,
          title: 'about'.tr(),
          onTap: () => push(context, const AboutView()),
        ),
        if (loggedIn) ...[
          spaceH(12),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: ListTile(
              onTap: () => _logout(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: Text('logout'.tr(),
                  style: AppStyles.semiBold14
                      .copyWith(color: AppColors.danger)),
            ),
          ),
        ],
      ],
    );
  }
}
