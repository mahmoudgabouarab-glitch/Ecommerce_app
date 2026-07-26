import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../data/models/product_model.dart';
import '../../view_model/suggested_cubit/suggested_cubit.dart';
import '../details_view.dart';

class SuggestedProductsSection extends StatelessWidget {
  const SuggestedProductsSection({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuggestedCubit, SuggestedState>(
      builder: (context, state) {
        if (state is! SuggestedSuccess || state.products.isEmpty) {
          return const SizedBox.shrink();
        }
        final products = state.products;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppStyles.bold20),
            SizedBox(height: 14.h),
            SizedBox(
              height: 235.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: products.length,
                separatorBuilder: (_, _) => SizedBox(width: 12.w),
                itemBuilder: (_, i) => _SuggestedCard(product: products[i]),
              ),
            ),
            SizedBox(height: 22.h),
          ],
        );
      },
    );
  }
}

class _SuggestedCard extends StatelessWidget {
  const _SuggestedCard({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => push(context, DetailsView(productId: product.id)),
      child: Container(
        width: 150.w,
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
              height: 130.h,
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
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: AppColors.star, size: 14.r),
                      SizedBox(width: 3.w),
                      Text('${product.rating}',
                          style: AppStyles.regular12
                              .copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                  SizedBox(height: 6.h),
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
