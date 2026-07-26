import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/product_model.dart';

class ProductDescription extends StatelessWidget {
  const ProductDescription({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('description'.tr(), style: AppStyles.semiBold16),
        SizedBox(height: 8.h),
        Text(product.description,
            style: AppStyles.regular14
                .copyWith(color: cs.onSurfaceVariant, height: 1.6)),
      ],
    );
  }
}
