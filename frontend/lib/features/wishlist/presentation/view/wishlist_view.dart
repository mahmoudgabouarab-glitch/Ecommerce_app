import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/product_grid_shimmer.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../home/presentation/view/widgets/home/product_item.dart';
import '../view_model/wishlist_cubit/wishlist_cubit.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<WishlistCubit>().getWishlist();

    return Scaffold(
      appBar: AppBar(title: Text('wishlist'.tr())),
      body: SafeArea(
        child: BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, state) {
            if (state is WishlistLoading || state is WishlistInitial) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: const ProductGridShimmer(),
              );
            }
            if (state is WishlistError) {
              return ErrorState(
                message: state.error,
                onRetry: () => context.read<WishlistCubit>().getWishlist(),
              );
            }
            final products = (state as WishlistLoaded).products;
            if (products.isEmpty) {
              return EmptyState(
                icon: Icons.favorite_border,
                title: 'no_favorites'.tr(),
                subtitle: 'tap_heart'.tr(),
              );
            }
            return GridView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 0.66,
              ),
              itemBuilder: (context, i) => ProductItem(product: products[i]),
            );
          },
        ),
      ),
    );
  }
}
