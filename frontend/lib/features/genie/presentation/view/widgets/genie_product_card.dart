import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../home/presentation/view/details_view.dart';
import '../../../data/models/genie_product.dart';
import '../../../../../core/utils/spacing.dart';

class GenieProductCard extends StatelessWidget {
  const GenieProductCard({super.key, required this.product});

  final GenieProduct product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onSale = product.salePrice != null;

    return GestureDetector(
      onTap: () => push(context, DetailsView(productId: product.id)),
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: AspectRatio(
                aspectRatio: 1.25,
                child: (product.image != null && product.image!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: product.image!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: cs.surfaceContainerHigh),
                        errorWidget: (_, _, _) => Container(
                          color: cs.surfaceContainerHigh,
                          child: Icon(Icons.image_outlined,
                              color: cs.onSurfaceVariant),
                        ),
                      )
                    : Container(color: cs.surfaceContainerHigh),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiBold14,
                  ),
                  spaceH(6),
                  Row(
                    children: [
                      Text(
                        formatPrice(product.effectivePrice),
                        style: AppStyles.semiBold14
                            .copyWith(color: AppColors.primary),
                      ),
                      if (onSale) ...[
                        spaceW(6),
                        Expanded(
                          child: Text(
                            formatPrice(product.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.regular12.copyWith(
                              color: cs.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
