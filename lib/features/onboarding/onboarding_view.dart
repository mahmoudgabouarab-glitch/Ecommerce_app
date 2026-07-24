import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/network/cache_helper.dart';
import '../../core/network/cache_keys.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_functions.dart';
import '../../core/utils/styles.dart';
import '../auth/presentation/view/login_view.dart';

class _Page {
  const _Page(this.icon, this.title, this.desc, this.colors);
  final IconData icon;
  final String title;
  final String desc;
  final List<Color> colors;
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _Page(Icons.storefront_rounded, 'onboard1_title', 'onboard1_desc',
        [Color(0xFFFB923C), Color(0xFFF97316)]),
    _Page(Icons.shopping_bag_rounded, 'onboard2_title', 'onboard2_desc',
        [Color(0xFF6366F1), Color(0xFF4338CA)]),
    _Page(Icons.local_shipping_rounded, 'onboard3_title', 'onboard3_desc',
        [Color(0xFF10B981), Color(0xFF059669)]),
  ];

  bool get _isLast => _index == _pages.length - 1;

  void _finish() {
    CacheHelper.saveData(key: CacheKeys.onboardingSeen, value: true);
    pushAndRemoveUntil(context, const LoginView());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _finish,
                child: Text('skip'.tr(),
                    style: AppStyles.semiBold14
                        .copyWith(color: cs.onSurfaceVariant)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: EdgeInsets.all(28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180.r,
                          height: 180.r,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: p.colors),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: p.colors.last.withValues(alpha: 0.35),
                                blurRadius: 34,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Icon(p.icon, color: Colors.white, size: 84.r),
                        ),
                        SizedBox(height: 44.h),
                        Text(p.title.tr(),
                            textAlign: TextAlign.center,
                            style: AppStyles.bold28),
                        SizedBox(height: 14.h),
                        Text(p.desc.tr(),
                            textAlign: TextAlign.center,
                            style: AppStyles.regular14.copyWith(
                                color: cs.onSurfaceVariant, height: 1.7)),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _index == i ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color:
                        _index == i ? AppColors.primary : cs.outlineVariant,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r)),
                  ),
                  onPressed: () {
                    if (_isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(_isLast ? 'get_started'.tr() : 'next'.tr(),
                      style: AppStyles.semiBold16.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
