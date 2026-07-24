import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../auth/presentation/view/widgets/login_required.dart';
import '../../../../../cart/presentation/view_model/add_to_cart_cubit/add_to_cart_cubit.dart';
import '../../../../data/models/product_model.dart';
import '../../../view_model/details_cubit/details_cubit.dart';
import '../suggested_products_section.dart';
import 'product_gallery.dart';
import 'reviews_section.dart';

class DetailsBody extends StatelessWidget {
  const DetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsCubit, DetailsState>(
      builder: (context, state) {
        if (state is DetailsLoading || state is DetailsInitial) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is DetailsFailure) {
          return Center(
              child: Text(state.error,
                  style: AppStyles.regular14
                      .copyWith(color: AppStyles.muted(context))));
        }
        return _DetailsContent(product: (state as DetailsSuccess).product);
      },
    );
  }
}

class _DetailsContent extends StatefulWidget {
  const _DetailsContent({required this.product});
  final ProductModel product;

  @override
  State<_DetailsContent> createState() => _DetailsContentState();
}

class _DetailsContentState extends State<_DetailsContent> {
  ProductVariantModel? _selected;

  ProductModel get product => widget.product;

  double get _price =>
      product.effectivePrice + (_selected?.priceDiff ?? 0);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              ProductGallery(images: product.images),
              SizedBox(height: 20.h),
              Row(
                children: [
                  if (product.categoryName != null)
                    _Pill(text: product.categoryName!),
                  const Spacer(),
                  Icon(Icons.star_rounded, color: AppColors.star, size: 20.r),
                  SizedBox(width: 4.w),
                  Text('${product.rating}', style: AppStyles.semiBold14),
                  Text('  (${product.ratingCount})',
                      style: AppStyles.regular12
                          .copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
              SizedBox(height: 14.h),
              Text(product.title, style: AppStyles.bold24),
              if (product.brand != null) ...[
                SizedBox(height: 6.h),
                Text('by ${product.brand}',
                    style: AppStyles.regular14
                        .copyWith(color: cs.onSurfaceVariant)),
              ],
              // --- Variant selector ---
              if (product.variants.isNotEmpty) ...[
                SizedBox(height: 18.h),
                Text('size'.tr(), style: AppStyles.semiBold16),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: product.variants.map((v) {
                    final selected = _selected?.id == v.id;
                    final disabled = v.stock <= 0;
                    return GestureDetector(
                      onTap: disabled
                          ? null
                          : () => setState(() => _selected = v),
                      child: Container(
                        constraints: BoxConstraints(minWidth: 48.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(
                                  colors: AppColors.brandGradient)
                              : null,
                          color: selected ? null : cs.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: selected ? Colors.transparent : cs.outline,
                          ),
                        ),
                        child: Text(
                          v.label,
                          style: AppStyles.semiBold14.copyWith(
                            color: selected
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
              SizedBox(height: 18.h),
              Text('description'.tr(), style: AppStyles.semiBold16),
              SizedBox(height: 8.h),
              Text(product.description,
                  style: AppStyles.regular14
                      .copyWith(color: cs.onSurfaceVariant, height: 1.6)),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Icon(
                    product.inStock ? Icons.check_circle : Icons.remove_circle,
                    color:
                        product.inStock ? AppColors.success : AppColors.danger,
                    size: 18.r,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    product.inStock
                        ? 'in_stock'.tr(args: ['${product.stock}'])
                        : 'out_of_stock'.tr(),
                    style: AppStyles.medium14.copyWith(
                      color:
                          product.inStock ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              ReviewsSection(productId: product.id),
              SizedBox(height: 28.h),
              SuggestedProductsSection(title: 'similar_products'.tr()),
            ],
          ),
        ),
        _bottomBar(context),
      ],
    );
  }

  Widget _bottomBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('price'.tr(),
                  style: AppStyles.regular12
                      .copyWith(color: cs.onSurfaceVariant)),
              SizedBox(height: 2.h),
              Text(formatPrice(_price),
                  style: AppStyles.bold24.copyWith(color: AppColors.primary)),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: BlocConsumer<AddToCartCubit, AddToCartState>(
              listener: (context, s) {
                if (s is AddToCartSuccess) {
                  showSnackBar(context, 'added_to_cart'.tr(), success: true);
                } else if (s is AddToCartFailure) {
                  showSnackBar(context, s.error);
                }
              },
              builder: (context, s) => CustomButton(
                text: 'add_to_cart'.tr(),
                icon: Icons.shopping_bag_outlined,
                isLoading: s is AddToCartLoading,
                onPressed: product.inStock ? () => _addToCart(context) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    if (!isLoggedInUser()) {
      showLoginRequired(context);
      return;
    }
    // Require a selection when the product has variants.
    if (product.variants.isNotEmpty && _selected == null) {
      showSnackBar(context, 'select_variant'.tr());
      return;
    }
    context.read<AddToCartCubit>().addToCart(
          productId: product.id,
          variantId: _selected?.id,
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
