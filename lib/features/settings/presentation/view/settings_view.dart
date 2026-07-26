import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/cache_helper.dart';
import '../../../../core/network/cache_keys.dart';
import '../../../../core/network/service_locator.dart';
import '../../../../core/services/push_service.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/styles.dart';
import '../../../address/presentation/view/addresses_view.dart';
import '../../../admin/presentation/view/admin_dashboard_view.dart';
import '../../../auth/data/repo/auth_repo_impl.dart';
import '../../../auth/presentation/view/login_view.dart';
import '../../../auth/presentation/view/change_password_view.dart';
import '../../../notifications/presentation/view/notifications_view.dart';
import '../../../notifications/presentation/view_model/notifications_cubit/notifications_cubit.dart';
import '../../../wishlist/presentation/view/wishlist_view.dart';
import 'about_view.dart';
import 'edit_profile_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
    if (changed == true && mounted) setState(() {}); // refresh header
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

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr()),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => context.read<ThemeCubit>().toggle(context),
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            if (loggedIn)
              _HeaderCard(
                name: name,
                email: email,
                avatar: avatar,
                onEdit: _editProfile,
              )
            else
              _GuestHeader(),
            if (loggedIn) ...[
              SizedBox(height: 16.h),
              const _PersonalInfoCard(),
            ],
            SizedBox(height: 12.h),
            Text('appearance'.tr(), style: AppStyles.semiBold16),
            SizedBox(height: 12.h),
            const _ThemeSelector(),
            SizedBox(height: 22.h),
            Text('language'.tr(), style: AppStyles.semiBold16),
            SizedBox(height: 12.h),
            const _LanguageSelector(),
            SizedBox(height: 22.h),
            if (loggedIn && isAdmin) ...[
              Text('admin'.tr(), style: AppStyles.semiBold16),
              SizedBox(height: 12.h),
              _tile(context, Icons.dashboard_outlined, 'admin_dashboard'.tr(),
                  onTap: () => push(context, const AdminDashboardView())),
              SizedBox(height: 12.h),
            ],
            Text('account'.tr(), style: AppStyles.semiBold16),
            SizedBox(height: 12.h),
            if (loggedIn) ...[
              _tile(context, Icons.person_outline, 'edit_profile'.tr(),
                  onTap: _editProfile),
              _tile(context, Icons.lock_outline, 'change_password'.tr(),
                  onTap: () => push(context, const ChangePasswordView())),
              _tile(context, Icons.location_on_outlined, 'addresses'.tr(),
                  onTap: () => push(context, const AddressesView())),
              _tile(context, Icons.favorite_outline, 'wishlist'.tr(),
                  onTap: () => push(context, const WishlistView())),
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, _) => _tile(
                  context,
                  Icons.notifications_outlined,
                  'notifications'.tr(),
                  badgeCount: context.read<NotificationsCubit>().unreadCount,
                  onTap: () => push(context, const NotificationsView()),
                ),
              ),
            ],
            _tile(context, Icons.info_outline, 'about'.tr(),
                onTap: () => push(context, const AboutView())),
            if (loggedIn) ...[
              SizedBox(height: 12.h),
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
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title,
      {VoidCallback? onTap, int badgeCount = 0}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.r),
        ),
        title: Text(title, style: AppStyles.medium14),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Header shown to guests — invites them to log in.
class _GuestHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.brandGradient),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Icon(Icons.person_outline, color: Colors.white, size: 30.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text('login_required_msg'.tr(),
                style: AppStyles.semiBold16.copyWith(color: Colors.white)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            onPressed: () => pushAndRemoveUntil(context, const LoginView()),
            child: Text('login_now'.tr()),
          ),
        ],
      ),
    );
  }
}

/// Card showing the user's extra details (phone, gender, birthday, bio).
class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String? val(String key) {
      final v = CacheHelper.getDataString(key: key);
      return (v == null || v.isEmpty) ? null : v;
    }

    final phone = val(CacheKeys.userPhone);
    final gender = val(CacheKeys.userGender);
    final birth = val(CacheKeys.userBirthDate);
    final bio = val(CacheKeys.userBio);

    // Nothing to show yet.
    if (phone == null && gender == null && birth == null && bio == null) {
      return const SizedBox.shrink();
    }

    final rows = <Widget>[
      if (phone != null) _row(context, Icons.phone_outlined, 'phone'.tr(), phone),
      if (gender != null)
        _row(context, Icons.wc_outlined, 'gender'.tr(), gender.tr()),
      if (birth != null)
        _row(context, Icons.cake_outlined, 'birth_date'.tr(), birth),
      if (bio != null) _row(context, Icons.info_outline, 'bio'.tr(), bio),
    ];

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
          Text('personal_info'.tr(), style: AppStyles.semiBold16),
          SizedBox(height: 4.h),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.r, color: AppColors.primary),
          SizedBox(width: 12.w),
          Text('$label:  ',
              style: AppStyles.medium14.copyWith(color: cs.onSurfaceVariant)),
          Expanded(
            child: Text(value, style: AppStyles.medium14),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.name,
    required this.email,
    required this.avatar,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String? avatar;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.brandGradient),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(name: name, avatar: avatar),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppStyles.bold20.copyWith(color: Colors.white)),
                  SizedBox(height: 4.h),
                  Text(email,
                      style: AppStyles.regular14.copyWith(
                          color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            Icon(Icons.edit_outlined,
                color: Colors.white.withValues(alpha: 0.9), size: 22.r),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.avatar});
  final String name;
  final String? avatar;

  @override
  Widget build(BuildContext context) {
    final hasImage = avatar != null && avatar!.isNotEmpty;
    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.25),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: avatar!,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _initial(),
            )
          : _initial(),
    );
  }

  Widget _initial() => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
}

/// English / Arabic language selector wired to easy_localization.
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = context.locale.languageCode;

    Widget option(String code, String label) {
      final selected = current == code;
      return Expanded(
        child: GestureDetector(
          onTap: () => context.setLocale(Locale(code)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(colors: AppColors.brandGradient)
                  : null,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: AppStyles.semiBold14.copyWith(
                  color: selected ? Colors.white : cs.onSurfaceVariant,
                )),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          option('en', 'English'),
          option('ar', 'العربية'),
        ],
      ),
    );
  }
}

/// System / Light / Dark segmented selector wired to [ThemeCubit].
class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              _option(context, mode, ThemeMode.system, Icons.brightness_auto,
                  'system'.tr()),
              _option(context, mode, ThemeMode.light, Icons.light_mode_outlined,
                  'light'.tr()),
              _option(context, mode, ThemeMode.dark, Icons.dark_mode_outlined,
                  'dark'.tr()),
            ],
          ),
        );
      },
    );
  }

  Widget _option(BuildContext context, ThemeMode current, ThemeMode value,
      IconData icon, String label) {
    final cs = Theme.of(context).colorScheme;
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<ThemeCubit>().setMode(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: AppColors.brandGradient)
                : null,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22.r,
                  color: selected ? Colors.white : cs.onSurfaceVariant),
              SizedBox(height: 4.h),
              Text(label,
                  style: AppStyles.regular12.copyWith(
                    color: selected ? Colors.white : cs.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
