import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/recently_viewed.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/product_model.dart';
import '../../details_view.dart';
import '../../../../../../core/utils/spacing.dart';

class RecentlyViewedSection extends StatelessWidget {
  const RecentlyViewedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: RecentlyViewed.revision,
      builder: (context, _, _) {
        final products = RecentlyViewed.items();
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('recently_viewed'.tr(), style: AppStyles.bold20),
            spaceH(14),
            SizedBox(
              height: 215.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: products.length,
                separatorBuilder: (_, _) => spaceW(12),
                itemBuilder: (_, i) => _RecentCard(product: products[i]),
              ),
            ),
            spaceH(22),
          ],
        );
      },
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => push(context, DetailsView(productId: product.id)),
      child: Container(
        width: 140.w,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120.h,
              width: double.infinity,
              color: cs.surfaceContainerHigh,
              child: CachedNetworkImage(
                imageUrl: product.image,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: cs.surfaceContainerHigh),
                errorWidget: (_, _, _) =>
                    Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.semiBold14),
                  spaceH(6),
                  Text(formatPrice(product.effectivePrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
