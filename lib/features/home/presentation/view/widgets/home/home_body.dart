import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/network/cache_helper.dart';
import '../../../../../../core/network/cache_keys.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/product_grid_shimmer.dart';
import '../../../../../../core/widgets/state_views.dart';
import '../../../../../notifications/presentation/view/notifications_view.dart';
import '../../../../../notifications/presentation/view_model/notifications_cubit/notifications_cubit.dart';
import '../../../view_model/products_cubit/products_cubit.dart';
import '../../search_view.dart';
import '../suggested_products_section.dart';
import 'category_list.dart';
import 'home_banner.dart';
import 'product_item.dart';

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
    // Trigger the next page when within 300px of the bottom.
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
          _Header(name: name),
          SizedBox(height: 20.h),
          _SearchBar(
            onOpen: () => push(context, const SearchView()),
            onFilter: () => _openFilterSheet(context),
          ),
          SizedBox(height: 20.h),
          const HomeBanner(),
          SizedBox(height: 22.h),
          const CategoryList(),
          SizedBox(height: 22.h),
          SuggestedProductsSection(title: 'recommended_for_you'.tr()),
          Text('popular_products'.tr(), style: AppStyles.bold20),
          SizedBox(height: 14.h),
          BlocBuilder<ProductsCubit, ProductsState>(
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
                            color: AppColors.primary),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

void _openFilterSheet(BuildContext context) {
  final cubit = context.read<ProductsCubit>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _FilterSheet(cubit: cubit),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.cubit});
  final ProductsCubit cubit;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const double _min = 0;
  static const double _max = 3000;

  late RangeValues _range = RangeValues(
    widget.cubit.minPrice ?? _min,
    widget.cubit.maxPrice ?? _max,
  );
  late String? _sort = widget.cubit.sort;

  static const _sorts = {
    'newest': 'newest',
    'price_asc': 'price_low_high',
    'price_desc': 'price_high_low',
    'rating': 'top_rated',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text('filter_sort'.tr(), style: AppStyles.bold20),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('price_range'.tr(), style: AppStyles.semiBold16),
                Text(
                    '${_range.start.round()} - ${_range.end.round()} EGP',
                    style: AppStyles.medium14.copyWith(color: AppColors.primary)),
              ],
            ),
            RangeSlider(
              values: _range,
              min: _min,
              max: _max,
              divisions: 30,
              activeColor: AppColors.primary,
              labels: RangeLabels(
                '${_range.start.round()}',
                '${_range.end.round()}',
              ),
              onChanged: (v) => setState(() => _range = v),
            ),
            SizedBox(height: 12.h),
            Text('sort_by'.tr(), style: AppStyles.semiBold16),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: _sorts.entries.map((e) {
                final selected = _sort == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _sort = selected ? null : e.key),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(colors: AppColors.brandGradient)
                          : null,
                      color: selected ? null : cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(e.value.tr(),
                        style: AppStyles.regular12.copyWith(
                          color: selected ? Colors.white : cs.onSurfaceVariant,
                        )),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'reset'.tr(),
                    outlined: true,
                    onPressed: () {
                      widget.cubit.getProducts(resetFilters: true);
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'apply'.tr(),
                    onPressed: () {
                      widget.cubit.applyFilters(
                        sort: _sort,
                        minPrice: _range.start > _min ? _range.start : null,
                        maxPrice: _range.end < _max ? _range.end : null,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('hello'.tr(args: [name]),
                  style: AppStyles.regular14
                      .copyWith(color: cs.onSurfaceVariant)),
              SizedBox(height: 2.h),
              Text('find_favorite'.tr(), style: AppStyles.bold24),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        const _NotificationBell(),
      ],
    );
  }
}

/// Bell button in the home header that opens notifications and shows the
/// unread count as a badge.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => push(context, const NotificationsView()),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: cs.outline),
        ),
        alignment: Alignment.center,
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, _) {
            final count = context.read<NotificationsCubit>().unreadCount;
            return Badge(
              isLabelVisible: count > 0,
              backgroundColor: AppColors.danger,
              label: Text(count > 99 ? '99+' : '$count'),
              offset: Offset(6.w, -6.h),
              child: Icon(Icons.notifications_outlined,
                  color: cs.onSurface, size: 24.r),
            );
          },
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onOpen, required this.onFilter});
  final VoidCallback onOpen;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onOpen,
            child: Container(
              height: 52.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: cs.onSurfaceVariant),
                  SizedBox(width: 10.w),
                  Text('search_products'.tr(),
                      style: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 15.sp)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: onFilter,
          child: Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.brandGradient),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
