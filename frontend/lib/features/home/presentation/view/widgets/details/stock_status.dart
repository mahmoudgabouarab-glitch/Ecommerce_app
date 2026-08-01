import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/product_model.dart';
import '../../../../../../core/utils/spacing.dart';

class StockStatus extends StatelessWidget {
  const StockStatus({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          product.inStock ? Icons.check_circle : Icons.remove_circle,
          color: product.inStock ? AppColors.success : AppColors.danger,
          size: 18.r,
        ),
        spaceW(6),
        Text(
          product.inStock
              ? 'in_stock'.tr(args: ['${product.stock}'])
              : 'out_of_stock'.tr(),
          style: AppStyles.medium14.copyWith(
            color: product.inStock ? AppColors.success : AppColors.danger,
          ),
        ),
      ],
    );
  }
}
