import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../auth/presentation/view/widgets/login_required.dart';
import '../../../../../wishlist/presentation/view_model/wishlist_cubit/wishlist_cubit.dart';
import '../../../../data/models/product_model.dart';
import '../../details_view.dart';

/// A polished product card used in the home grid.
class ProductItem extends StatelessWidget {
  const ProductItem({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => push(context, DetailsView(productId: product.id)),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: cs.surfaceContainerHigh),
                        errorWidget: (_, _, _) => Icon(
                          Icons.image_outlined,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  if (product.onSale)
                    Positioned(
                      top: 14.h,
                      left: 14.w,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Text('SALE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                            )),
                      ),
                    ),
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: _WishlistHeart(productId: product.id),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.categoryName != null)
                    Text(product.categoryName!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.primary,
                        )),
                  SizedBox(height: 3.h),
                  Text(product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.semiBold14),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.star, size: 15.r),
                      SizedBox(width: 3.w),
                      Text('${product.rating}',
                          style: AppStyles.regular12
                              .copyWith(color: cs.onSurfaceVariant)),
                      Text(' (${product.ratingCount})',
                          style: AppStyles.regular12
                              .copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(formatPrice(product.effectivePrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.price),
                      ),
                      SizedBox(width: 6.w),
                      if (product.onSale)
                        Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Text(formatPrice(product.price),
                              style: AppStyles.regular12.copyWith(
                                color: cs.onSurfaceVariant,
                                decoration: TextDecoration.lineThrough,
                              )),
                        ),
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

/// Favorite toggle that reflects and updates the shared [WishlistCubit].
class _WishlistHeart extends StatelessWidget {
  const _WishlistHeart({required this.productId});
  final int productId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Rebuild whenever the wishlist changes.
    context.watch<WishlistCubit>();
    final isFav = context.read<WishlistCubit>().isFavorite(productId);

    return GestureDetector(
      onTap: () {
        if (!isLoggedInUser()) {
          showLoginRequired(context);
          return;
        }
        context.read<WishlistCubit>().toggle(productId);
      },
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          size: 17.r,
          color: isFav ? AppColors.danger : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
