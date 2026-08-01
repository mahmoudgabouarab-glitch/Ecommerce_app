import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/skeletons.dart';
import '../../../../data/models/product_model.dart';
import '../../../view_model/details_cubit/details_cubit.dart';
import '../suggested_products_section.dart';
import 'details_bottom_bar.dart';
import 'product_description.dart';
import 'product_gallery.dart';
import 'product_info.dart';
import 'rating_summary.dart';
import 'reviews_section.dart';
import 'stock_status.dart';
import 'variant_selector.dart';
import '../../../../../../core/utils/spacing.dart';

class DetailsBody extends StatelessWidget {
  const DetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsCubit, DetailsState>(
      builder: (context, state) {
        if (state is DetailsLoading || state is DetailsInitial) {
          return const DetailsShimmer();
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
              ProductGallery(
                images: product.images,
                heroTag: 'product-image-${product.id}',
              ),
              spaceH(20),
              ProductInfo(product: product),
              if (product.variants.isNotEmpty) ...[
                spaceH(18),
                VariantSelector(
                  product: product,
                  selected: _selected,
                  onSelect: (v) => setState(() => _selected = v),
                ),
              ],
              spaceH(18),
              ProductDescription(product: product),
              spaceH(18),
              StockStatus(product: product),
              spaceH(24),
              RatingSummary(product: product),
              spaceH(16),
              ReviewsSection(productId: product.id),
              spaceH(28),
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
