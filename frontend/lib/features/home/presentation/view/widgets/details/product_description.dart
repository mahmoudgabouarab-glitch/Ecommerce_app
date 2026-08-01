import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/product_model.dart';
import '../../../../../../core/utils/spacing.dart';

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
        spaceH(8),
        Text(product.description,
            style: AppStyles.regular14
                .copyWith(color: cs.onSurfaceVariant, height: 1.6)),
      ],
    );
  }
}
