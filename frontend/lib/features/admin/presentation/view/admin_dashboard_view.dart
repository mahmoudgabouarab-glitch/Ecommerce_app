import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../home/data/repo/home_repo_impl.dart';
import '../../data/repo/admin_repo_impl.dart';
import '../view_model/admin_banners_cubit/admin_banners_cubit.dart';
import '../view_model/admin_categories_cubit/admin_categories_cubit.dart';
import '../view_model/admin_coupons_cubit/admin_coupons_cubit.dart';
import '../view_model/admin_products_cubit/admin_products_cubit.dart';
import '../view_model/admin_users_cubit/admin_users_cubit.dart';
import 'widgets/admin_banners_tab.dart';
import 'widgets/admin_categories_tab.dart';
import 'widgets/admin_coupons_tab.dart';
import 'widgets/admin_orders_tab.dart';
import 'widgets/admin_products_tab.dart';
import 'widgets/admin_users_tab.dart';
import 'widgets/overview_tab.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text('admin_dashboard'.tr()),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'overview'.tr()),
              Tab(text: 'orders'.tr()),
              Tab(text: 'products'.tr()),
              Tab(text: 'categories'.tr()),
              Tab(text: 'coupons'.tr()),
              Tab(text: 'banners'.tr()),
              Tab(text: 'users'.tr()),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              const OverviewTab(),
              const AdminOrdersTab(),
              BlocProvider(
                create: (_) => AdminProductsCubit(
                  getIt<AdminRepoImpl>(),
                  getIt<HomeRepoImpl>(),
                )..getProducts(),
                child: const AdminProductsTab(),
              ),
              BlocProvider(
                create: (_) => AdminCategoriesCubit(
                  getIt<AdminRepoImpl>(),
                  getIt<HomeRepoImpl>(),
                )..getCategories(),
                child: const AdminCategoriesTab(),
              ),
              BlocProvider(
                create: (_) =>
                    AdminCouponsCubit(getIt<AdminRepoImpl>())..getCoupons(),
                child: const AdminCouponsTab(),
              ),
              BlocProvider(
                create: (_) =>
                    AdminBannersCubit(getIt<AdminRepoImpl>())..getBanners(),
                child: const AdminBannersTab(),
              ),
              BlocProvider(
                create: (_) =>
                    AdminUsersCubit(getIt<AdminRepoImpl>())..getUsers(),
                child: const AdminUsersTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
