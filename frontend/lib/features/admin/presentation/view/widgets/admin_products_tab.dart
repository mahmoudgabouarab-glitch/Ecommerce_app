import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../../../home/data/models/product_model.dart';
import '../../view_model/admin_products_cubit/admin_products_cubit.dart';
import 'product_form_sheet.dart';

class AdminProductsTab extends StatelessWidget {
  const AdminProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => openProductForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('add_product'.tr(),
            style: const TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<AdminProductsCubit, AdminProductsState>(
        listener: (context, state) {
          if (state is AdminProductsFailure) showSnackBar(context, state.error);
        },
        builder: (context, state) {
          if (state is AdminProductsLoading || state is AdminProductsInitial) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final products =
              state is AdminProductsLoaded ? state.products : <ProductModel>[];
          if (products.isEmpty) {
            return EmptyState(
                icon: Icons.inventory_2_outlined, title: 'no_products'.tr());
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 90.h),
            itemCount: products.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, i) => _AdminProductTile(product: products[i]),
          );
        },
      ),
    );
  }
}

class _AdminProductTile extends StatelessWidget {
  const _AdminProductTile({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedNetworkImage(
              imageUrl: product.image,
              width: 56.w,
              height: 56.w,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  Container(color: cs.surfaceContainerHigh, width: 56.w, height: 56.w),
              errorWidget: (_, _, _) =>
                  Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiBold14),
                SizedBox(height: 2.h),
                Text(
                    '${formatPrice(product.effectivePrice)} • ${'stock'.tr()} ${product.stock}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.regular12.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => openProductForm(context, existing: product),
            icon: Icon(Icons.edit_outlined, size: 20.r, color: cs.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, product.id),
            icon: Icon(Icons.delete_outline, size: 20.r, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final cubit = context.read<AdminProductsCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_product_q'.tr()),
        content: Text('cannot_undone'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              cubit.deleteProduct(id);
              Navigator.pop(context);
            },
            child: Text('delete'.tr(),
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
