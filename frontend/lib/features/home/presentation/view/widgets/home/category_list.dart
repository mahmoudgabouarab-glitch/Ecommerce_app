import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../view_model/categories_cubit/categories_cubit.dart';
import '../../../view_model/products_cubit/products_cubit.dart';
import 'home_shimmers.dart';
import '../../../../../../core/utils/spacing.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int? _selectedId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading || state is CategoriesInitial) {
          return const CategoryChipsShimmer();
        }
        if (state is! CategoriesSuccess) return spaceH(42);

        final ids = [null, ...state.categories.map((c) => c.id)];
        final names = ['all'.tr(), ...state.categories.map((c) => c.name)];

        return SizedBox(
          height: 42.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ids.length,
            separatorBuilder: (_, _) => spaceW(10),
            itemBuilder: (context, i) {
              final selected = _selectedId == ids[i];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedId = ids[i]);
                  context.read<ProductsCubit>().filterByCategory(ids[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(colors: AppColors.brandGradient)
                        : null,
                    color: selected ? null : cs.surface,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: selected ? Colors.transparent : cs.outline,
                    ),
                  ),
                  child: Text(
                    names[i],
                    style: AppStyles.semiBold14.copyWith(
                      color: selected ? Colors.white : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
