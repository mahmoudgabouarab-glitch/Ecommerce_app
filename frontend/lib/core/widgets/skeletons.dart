import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWrap extends StatelessWidget {
  const ShimmerWrap({super.key, required this.child});
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

class ListRowsShimmer extends StatelessWidget {
  const ListRowsShimmer({super.key, this.count = 6, this.rowHeight = 78});
  final int count;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ShimmerWrap(
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (_, _) => Container(
          height: rowHeight.h,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

class DetailsShimmer extends StatelessWidget {
  const DetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget bar(double w, double h) => Container(
          width: w,
          height: h.h,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
        );
    return ShimmerWrap(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(height: 320.h, color: cs.surface),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(220.w, 22),
                SizedBox(height: 12.h),
                bar(120.w, 18),
                SizedBox(height: 20.h),
                bar(double.infinity, 14),
                SizedBox(height: 10.h),
                bar(double.infinity, 14),
                SizedBox(height: 10.h),
                bar(240.w, 14),
                SizedBox(height: 24.h),
                Row(
                  children: List.generate(
                    3,
                    (_) => Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: bar(70.w, 34),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
