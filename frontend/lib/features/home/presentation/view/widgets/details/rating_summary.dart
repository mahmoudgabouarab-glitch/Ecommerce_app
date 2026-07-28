import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/product_model.dart';

class RatingSummary extends StatelessWidget {
  const RatingSummary({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (product.ratingCount <= 0) return const SizedBox.shrink();
    final total = product.ratingCount;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(product.rating.toStringAsFixed(1), style: AppStyles.bold28),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final filled = i < product.rating.round();
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 15.r,
                    color: AppColors.star,
                  );
                }),
              ),
              SizedBox(height: 4.h),
              Text('$total ${'reviews'.tr()}',
                  style:
                      AppStyles.regular12.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              children: [
                for (var star = 5; star >= 1; star--)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      children: [
                        Text('$star',
                            style: AppStyles.regular12
                                .copyWith(color: cs.onSurfaceVariant)),
                        SizedBox(width: 4.w),
                        Icon(Icons.star_rounded,
                            size: 12.r, color: AppColors.star),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: total == 0
                                  ? 0
                                  : (product.ratingsBreakdown[star] ?? 0) /
                                      total,
                              minHeight: 6.h,
                              backgroundColor: cs.surfaceContainerHigh,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        SizedBox(
                          width: 22.w,
                          child: Text(
                            '${product.ratingsBreakdown[star] ?? 0}',
                            textAlign: TextAlign.end,
                            style: AppStyles.regular12
                                .copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
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
