import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../view_model/products_cubit/products_cubit.dart';
import '../../../../../../core/utils/spacing.dart';

class ProductsHeader extends StatelessWidget {
  const ProductsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('popular_products'.tr(), style: AppStyles.bold20)),
        GestureDetector(
          onTap: () => _openFilterSheet(context),
          child: Container(
            width: 100.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.brandGradient),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 22.r),
          ),
        ),
      ],
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

  late final double _max = _resolveMax();

  late RangeValues _range = RangeValues(
    (widget.cubit.minPrice ?? _min).clamp(_min, _max).toDouble(),
    (widget.cubit.maxPrice ?? _max).clamp(_min, _max).toDouble(),
  );
  late String? _sort = widget.cubit.sort;

  double _resolveMax() {
    final m = widget.cubit.catalogMaxPrice;
    if (m == null || m <= 0) return 3000;
    return ((m / 100).ceil() * 100).toDouble();
  }

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
            spaceH(16),
            Text('filter_sort'.tr(), style: AppStyles.bold20),
            spaceH(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('price_range'.tr(), style: AppStyles.semiBold16),
                Text(
                  '${_range.start.round()} - ${_range.end.round()} EGP',
                  style: AppStyles.medium14.copyWith(color: AppColors.primary),
                ),
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
            spaceH(12),
            Text('sort_by'.tr(), style: AppStyles.semiBold16),
            spaceH(10),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: _sorts.entries.map((e) {
                final selected = _sort == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _sort = selected ? null : e.key),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              colors: AppColors.brandGradient,
                            )
                          : null,
                      color: selected ? null : cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      e.value.tr(),
                      style: AppStyles.regular12.copyWith(
                        color: selected ? Colors.white : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            spaceH(24),
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
                spaceW(12),
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
