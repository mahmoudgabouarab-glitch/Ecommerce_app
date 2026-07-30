import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../home/data/models/product_model.dart';
import 'compare_attribute_row.dart';
import 'compare_header.dart';

class CompareTable extends StatelessWidget {
  const CompareTable({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    final many = products.length > 1;
    final minPrice =
        products.map((p) => p.effectivePrice).reduce((a, b) => a < b ? a : b);
    final maxRating =
        products.map((p) => p.rating).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
          child: CompareHeader(products: products),
        ),
        Divider(height: 1.h),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CompareAttributeRow(
                  label: 'price'.tr(),
                  cells: products
                      .map((p) => _priceCell(
                          context, p, many && p.effectivePrice == minPrice))
                      .toList(),
                ),
                CompareAttributeRow(
                  label: 'rating'.tr(),
                  alt: true,
                  cells: products
                      .map((p) => _ratingCell(context, p,
                          many && maxRating > 0 && p.rating == maxRating))
                      .toList(),
                ),
                CompareAttributeRow(
                  label: 'brand'.tr(),
                  cells: products.map((p) => _textCell(p.brand)).toList(),
                ),
                CompareAttributeRow(
                  label: 'category'.tr(),
                  alt: true,
                  cells:
                      products.map((p) => _textCell(p.categoryName)).toList(),
                ),
                CompareAttributeRow(
                  label: 'stock'.tr(),
                  cells:
                      products.map((p) => _stockCell(context, p)).toList(),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceCell(BuildContext context, ProductModel p, bool win) {
    final text = formatPrice(p.effectivePrice);
    final Widget child = win
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 13.r, color: AppColors.success),
                SizedBox(width: 3.w),
                Text(text,
                    style: AppStyles.semiBold14
                        .copyWith(color: AppColors.success)),
              ],
            ),
          )
        : Text(text, style: AppStyles.semiBold14);

    return FittedBox(fit: BoxFit.scaleDown, child: child);
  }

  Widget _ratingCell(BuildContext context, ProductModel p, bool win) {
    final cs = Theme.of(context).colorScheme;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16.r, color: AppColors.star),
          SizedBox(width: 3.w),
          Text('${p.rating}',
              style: AppStyles.semiBold14.copyWith(
                  color: win ? AppColors.success : cs.onSurface)),
          SizedBox(width: 2.w),
          Text('(${p.ratingCount})',
              style: AppStyles.regular12.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _textCell(String? value) => Text(
        (value == null || value.isEmpty) ? '—' : value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppStyles.regular14,
      );

  Widget _stockCell(BuildContext context, ProductModel p) => Text(
        p.inStock ? 'in_stock'.tr(args: ['${p.stock}']) : 'out_of_stock'.tr(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppStyles.regular12.copyWith(
            color: p.inStock ? AppColors.success : AppColors.danger),
      );
}
