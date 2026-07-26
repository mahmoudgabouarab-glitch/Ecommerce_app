import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/product_model.dart';
import '../../../view_model/details_cubit/details_cubit.dart';
import '../suggested_products_section.dart';
import 'details_bottom_bar.dart';
import 'product_description.dart';
import 'product_gallery.dart';
import 'product_info.dart';
import 'reviews_section.dart';
import 'stock_status.dart';
import 'variant_selector.dart';

class DetailsBody extends StatelessWidget {
  const DetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsCubit, DetailsState>(
      builder: (context, state) {
        if (state is DetailsLoading || state is DetailsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is DetailsFailure) {
          return Center(
            child: Text(
              state.error,
              style: AppStyles.regular14.copyWith(
                color: AppStyles.muted(context),
              ),
            ),
          );
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

  double get _price => product.effectivePrice + (_selected?.priceDiff ?? 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              ProductGallery(images: product.images),
              SizedBox(height: 20.h),
              ProductInfo(product: product),
              if (product.variants.isNotEmpty) ...[
                SizedBox(height: 18.h),
                VariantSelector(
                  product: product,
                  selected: _selected,
                  onSelect: (v) => setState(() => _selected = v),
                ),
              ],
              SizedBox(height: 18.h),
              ProductDescription(product: product),
              SizedBox(height: 18.h),
              StockStatus(product: product),
              SizedBox(height: 24.h),
              ReviewsSection(productId: product.id),
              SizedBox(height: 28.h),
              SuggestedProductsSection(title: 'similar_products'.tr()),
            ],
          ),
        ),
        DetailsBottomBar(
          product: product,
          selectedVariant: _selected,
          price: _price,
        ),
      ],
    );
  }
}
