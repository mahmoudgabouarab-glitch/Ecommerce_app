import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/widgets/product_grid_shimmer.dart';
import '../../../../../../core/widgets/state_views.dart';
import '../../../view_model/products_cubit/products_cubit.dart';
import 'product_item.dart';

class PopularProductsBuild extends StatelessWidget {
  const PopularProductsBuild({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading || state is ProductsInitial) {
          return const ProductGridShimmer();
        }
        if (state is ProductsFailure) {
          return Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: ErrorState(
              message: state.error,
              onRetry: () => context.read<ProductsCubit>().getProducts(),
            ),
          );
        }
        final success = state as ProductsSuccess;
        final products = success.products;
        if (products.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: 30.h),
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'no_products'.tr(),
              subtitle: 'try_different'.tr(),
            ),
          );
        }
        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 0.66,
              ),
              itemBuilder: (context, i) =>
                  ProductItem(product: products[i]),
            ),
            if (success.loadingMore)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
