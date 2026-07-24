import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../cart/data/repo/cart_repo_impl.dart';
import '../../../cart/presentation/view_model/add_to_cart_cubit/add_to_cart_cubit.dart';
import '../../data/repo/home_repo_impl.dart';
import '../view_model/details_cubit/details_cubit.dart';
import '../view_model/reviews_cubit/reviews_cubit.dart';
import '../view_model/suggested_cubit/suggested_cubit.dart';
import 'widgets/details/details_body.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              DetailsCubit(getIt<HomeRepoImpl>())..getDetails(productId),
        ),
        BlocProvider(
          create: (_) =>
              ReviewsCubit(getIt<HomeRepoImpl>())..getReviews(productId),
        ),
        BlocProvider(
          create: (_) =>
              SuggestedCubit(getIt<HomeRepoImpl>())..loadRelated(productId),
        ),
        BlocProvider(
          create: (_) => AddToCartCubit(getIt<CartRepoImpl>()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          actions: [
            BlocBuilder<DetailsCubit, DetailsState>(
              builder: (context, state) {
                if (state is! DetailsSuccess) return const SizedBox.shrink();
                final p = state.product;
                return IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => Share.share(
                    'Check out "${p.title}" on E-Commerce App — '
                    '${formatPrice(p.effectivePrice)}',
                    subject: p.title,
                  ),
                );
              },
            ),
          ],
        ),
        body: const SafeArea(child: DetailsBody()),
      ),
    );
  }
}
