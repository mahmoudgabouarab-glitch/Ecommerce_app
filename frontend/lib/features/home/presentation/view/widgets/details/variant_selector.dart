import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/product_model.dart';
import '../../../../../../core/utils/spacing.dart';

class VariantSelector extends StatelessWidget {
  const VariantSelector({
    super.key,
    required this.product,
    required this.selected,
    required this.onSelect,
  });

  final ProductModel product;
  final ProductVariantModel? selected;
  final ValueChanged<ProductVariantModel> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('size'.tr(), style: AppStyles.semiBold16),
        spaceH(10),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: product.variants.map((v) {
            final isSelected = selected?.id == v.id;
            final disabled = v.stock <= 0;
            return GestureDetector(
              onTap: disabled ? null : () => onSelect(v),
              child: Container(
                constraints: BoxConstraints(minWidth: 48.w),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(colors: AppColors.brandGradient)
                      : null,
                  color: isSelected ? null : cs.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : cs.outline,
                  ),
                ),
                child: Text(
                  v.label,
                  style: AppStyles.semiBold14.copyWith(
                    color: isSelected
                        ? Colors.white
                        : disabled
                            ? cs.onSurfaceVariant.withValues(alpha: 0.4)
                            : cs.onSurface,
                    decoration:
                        disabled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
