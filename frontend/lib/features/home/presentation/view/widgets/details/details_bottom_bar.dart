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
import '../../../../../../core/utils/spacing.dart';

class DetailsBottomBar extends StatelessWidget {
  const DetailsBottomBar({
    super.key,
    required this.product,
    required this.selectedVariant,
    required this.price,
  });

  final ProductModel product;
  final ProductVariantModel? selectedVariant;
  final double price;

  @override
  Widget build(BuildContext context) {
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
              spaceH(2),
              Text(formatPrice(price),
                  style: AppStyles.bold24.copyWith(color: AppColors.primary)),
            ],
          ),
          spaceW(16),
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
    if (product.variants.isNotEmpty && selectedVariant == null) {
      showSnackBar(context, 'select_variant'.tr());
      return;
    }
    context.read<AddToCartCubit>().addToCart(
          productId: product.id,
          variantId: selectedVariant?.id,
        );
  }
}
