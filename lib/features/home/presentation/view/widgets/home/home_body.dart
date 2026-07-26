import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/network/cache_helper.dart';
import '../../../../../../core/network/cache_keys.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../view_model/products_cubit/products_cubit.dart';
import '../suggested_products_section.dart';
import 'category_list.dart';
import 'header.dart';
import 'home_banner.dart';
import 'popular_products_build.dart';
import 'products_header.dart';
import 'search_bar_home.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
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
    final name = CacheHelper.getDataString(key: CacheKeys.userName) ?? 'there';
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<ProductsCubit>().getProducts(),
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [
          Header(name: name),
          SizedBox(height: 20.h),
          const SearchBarHome(),
          SizedBox(height: 20.h),
          const HomeBanner(),
          SizedBox(height: 22.h),
          SuggestedProductsSection(title: 'recommended_for_you'.tr()),
          const ProductsHeader(),
          SizedBox(height: 14.h),
          const CategoryList(),
          SizedBox(height: 14.h),
          const PopularProductsBuild(),
        ],
      ),
    );
  }
}
