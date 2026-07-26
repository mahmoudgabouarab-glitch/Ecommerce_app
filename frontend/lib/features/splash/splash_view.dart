import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/network/cache_helper.dart';
import '../../core/network/cache_keys.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_functions.dart';
import '../../core/utils/styles.dart';
import '../auth/presentation/view/login_view.dart';
import '../main_layout.dart';
import '../onboarding/onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    final seenOnboarding =
        CacheHelper.getData(key: CacheKeys.onboardingSeen) == true;

    Widget next;
    if (!seenOnboarding) {
      next = const OnboardingView();
    } else if (isLoggedInUser() || isGuestUser()) {
      next = const MainLayout();
    } else {
      next = const LoginView();
    }
    pushAndRemoveUntil(context, next);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: _c,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(22.r),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: AppColors.brandGradient),
                    borderRadius: BorderRadius.circular(26.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(Icons.shopping_bag_rounded,
                      color: Colors.white, size: 52.r),
                ),
                SizedBox(height: 22.h),
                Text('app_name'.tr(), style: AppStyles.bold28),
                SizedBox(height: 6.h),
                Text('shop_smarter'.tr(),
                    style: AppStyles.regular14
                        .copyWith(color: AppStyles.muted(context))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
