import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/styles.dart';

class _Banner {
  const _Banner(this.title, this.subtitle, this.icon, this.colors);
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  static const _banners = [
    _Banner('Up to 30% OFF', 'On selected electronics', Icons.bolt_rounded,
        [Color(0xFFFB923C), Color(0xFFF97316)]),
    _Banner('Free Shipping', 'On orders over 1000 EGP', Icons.local_shipping_rounded,
        [Color(0xFF6366F1), Color(0xFF4338CA)]),
    _Banner('New Arrivals', 'Fresh styles just landed', Icons.auto_awesome_rounded,
        [Color(0xFF10B981), Color(0xFF059669)]),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final next = (_index + 1) % _banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _BannerCard(banner: _banners[i]),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: _index == i ? 20.w : 7.w,
              height: 7.h,
              decoration: BoxDecoration(
                color: _index == i
                    ? _banners[_index].colors.last
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});
  final _Banner banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: banner.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: banner.colors.last.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(banner.title,
                    style: AppStyles.bold24.copyWith(color: Colors.white)),
                SizedBox(height: 6.h),
                Text(banner.subtitle,
                    style: AppStyles.regular14
                        .copyWith(color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
          Icon(banner.icon,
              color: Colors.white.withValues(alpha: 0.9), size: 56.r),
        ],
      ),
    );
  }
}
