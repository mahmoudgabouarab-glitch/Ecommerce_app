import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/service_locator.dart';
import '../../data/repo/home_repo_impl.dart';
import '../view_model/categories_cubit/categories_cubit.dart';
import '../view_model/deals_cubit/deals_cubit.dart';
import '../view_model/products_cubit/products_cubit.dart';
import '../view_model/suggested_cubit/suggested_cubit.dart';
import 'widgets/home/home_body.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductsCubit(getIt<HomeRepoImpl>())..getProducts(),
        ),
        BlocProvider(
          create: (_) => CategoriesCubit(getIt<HomeRepoImpl>())..getCategories(),
        ),
        BlocProvider(
          create: (_) => SuggestedCubit(getIt<HomeRepoImpl>())..loadFeatured(),
        ),
        BlocProvider(
          create: (_) => DealsCubit(getIt<HomeRepoImpl>())..load(),
        ),
      ],
      child: const Scaffold(body: SafeArea(child: HomeBody())),
    );
  }
}
