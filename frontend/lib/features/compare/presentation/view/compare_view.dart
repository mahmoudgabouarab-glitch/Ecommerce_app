import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../home/data/models/product_model.dart';
import '../view_model/compare_cubit/compare_cubit.dart';
import 'widgets/compare_empty_state.dart';
import 'widgets/compare_table.dart';

class CompareView extends StatelessWidget {
  const CompareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('compare_title'.tr()),
        actions: [
          BlocBuilder<CompareCubit, CompareState>(
            builder: (context, state) {
              final hasItems = state is CompareUpdated && state.items.isNotEmpty;
              if (!hasItems) return const SizedBox.shrink();
              return TextButton(
                onPressed: context.read<CompareCubit>().clear,
                child: Text('clear'.tr(),
                    style: TextStyle(color: AppColors.danger)),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CompareCubit, CompareState>(
        builder: (context, state) {
          final products =
              state is CompareUpdated ? state.items : const <ProductModel>[];
          if (products.isEmpty) return const CompareEmptyState();
          return CompareTable(products: products);
        },
      ),
    );
  }
}
