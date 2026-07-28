import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/repo/home_repo_impl.dart';
import '../view_model/products_cubit/products_cubit.dart';
import 'widgets/home/popular_products_build.dart';

class CategoryProductsView extends StatelessWidget {
  const CategoryProductsView({
    super.key,
    required this.categoryId,
    required this.title,
  });

  final int categoryId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsCubit(getIt<HomeRepoImpl>())
        ..getProducts(categoryId: categoryId),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const SafeArea(child: _Body()),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<ProductsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<ProductsCubit>().getProducts(),
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        children: const [PopularProductsBuild()],
      ),
    );
  }
}
