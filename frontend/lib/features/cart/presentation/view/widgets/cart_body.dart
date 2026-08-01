import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/skeletons.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../../../auth/presentation/view/widgets/login_required.dart';
import '../../view_model/cart_cubit/cart_cubit.dart';
import 'cart_tile.dart';
import 'checkout_bar.dart';
import '../../../../../core/utils/spacing.dart';

class CartBody extends StatelessWidget {
  const CartBody({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isLoggedInUser()) {
      return GuestState(
          icon: Icons.shopping_cart_outlined, title: 'my_cart'.tr());
    }
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartActionError) showSnackBar(context, state.error);
      },
      builder: (context, state) {
        if (state is CartLoading || state is CartInitial) {
          return const ListRowsShimmer(rowHeight: 96);
        }
        if (state is CartFailure) {
          return ErrorState(
            message: state.error,
            onRetry: () => context.read<CartCubit>().getCart(),
          );
        }
        final cart =
            state is CartActionError ? state.cart : (state as CartSuccess).cart;
        if (cart.items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'cart_empty'.tr(),
            subtitle: 'browse_add'.tr(),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: cart.items.length,
                separatorBuilder: (_, _) => spaceH(12),
                itemBuilder: (context, i) => CartTile(item: cart.items[i]),
              ),
            ),
            CheckoutBar(subtotal: cart.subtotal, count: cart.count),
          ],
        );
      },
    );
  }
}
