import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/product_model.dart';

class ProductInfo extends StatelessWidget {
  const ProductInfo({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (product.categoryName != null)
              _Pill(text: product.categoryName!),
            const Spacer(),
            Icon(Icons.star_rounded, color: AppColors.star, size: 20.r),
            SizedBox(width: 4.w),
            Text('${product.rating}', style: AppStyles.semiBold14),
            Text('  (${product.ratingCount})',
                style: AppStyles.regular12.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
        SizedBox(height: 14.h),
        Text(product.title, style: AppStyles.bold24),
        if (product.brand != null) ...[
          SizedBox(height: 6.h),
          Text('by ${product.brand}',
              style: AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(text,
          style: AppStyles.semiBold14.copyWith(color: AppColors.primary)),
    );
  }
}
