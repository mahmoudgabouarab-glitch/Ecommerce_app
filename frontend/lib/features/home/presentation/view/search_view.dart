import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/repo/home_repo_impl.dart';
import '../view_model/search_cubit/search_cubit.dart';
import 'widgets/home/product_item.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(getIt<HomeRepoImpl>()),
      child: const _SearchScaffold(),
    );
  }
}

class _SearchScaffold extends StatefulWidget {
  const _SearchScaffold();

  @override
  State<_SearchScaffold> createState() => _SearchScaffoldState();
}

class _SearchScaffoldState extends State<_SearchScaffold> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchCubit>().search(q);
    });
  }

  void _submit(String q) {
    context.read<SearchCubit>().saveRecent(q);
    context.read<SearchCubit>().search(q);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90.h,
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: _submit,
          style: TextStyle(color: cs.onSurface, fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: 'search_products'.tr(),
            border: InputBorder.none,
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
        actions: [
          if (_hasText)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                context.read<SearchCubit>().search('');
              },
            ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is SearchFailure) {
              return ErrorState(message: state.error);
            }
            if (state is SearchResults) {
              if (state.products.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'no_products'.tr(),
                  subtitle: 'try_different'.tr(),
                );
              }
              return GridView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                  childAspectRatio: 0.66,
                ),
                itemBuilder: (context, i) =>
                    ProductItem(product: state.products[i]),
              );
            }
            final recent = state is SearchIdle ? state.recent : <String>[];
            if (recent.isEmpty) {
              return Center(
                child: Text(
                  'start_typing'.tr(),
                  style: AppStyles.regular14.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              );
            }
            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('recent_searches'.tr(), style: AppStyles.semiBold16),
                    TextButton(
                      onPressed: () =>
                          context.read<SearchCubit>().clearRecent(),
                      child: Text(
                        'clear'.tr(),
                        style: AppStyles.semiBold14.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: recent
                      .map(
                        (q) => GestureDetector(
                          onTap: () {
                            _controller.text = q;
                            _submit(q);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 9.h,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(30.r),
                              border: Border.all(color: cs.outline),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 16.r,
                                  color: cs.onSurfaceVariant,
                                ),
                                SizedBox(width: 6.w),
                                Text(q, style: AppStyles.regular14),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
