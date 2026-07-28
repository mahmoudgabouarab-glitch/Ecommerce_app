import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHigh,
      highlightColor: cs.surfaceContainerHighest,
      child: child,
    );
  }
}

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _ShimmerBox(
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}

class CategoryChipsShimmer extends StatelessWidget {
  const CategoryChipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _ShimmerBox(
      child: SizedBox(
        height: 42.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (_, _) => SizedBox(width: 10.w),
          itemBuilder: (_, _) => Container(
            width: 72.w,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(21.r),
            ),
          ),
        ),
      ),
    );
  }
}

class HCardsShimmer extends StatelessWidget {
  const HCardsShimmer({super.key, required this.height, this.cardWidth = 150});
  final double height;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _ShimmerBox(
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, _) => SizedBox(width: 12.w),
          itemBuilder: (_, _) => Container(
            width: cardWidth.w,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }
}
