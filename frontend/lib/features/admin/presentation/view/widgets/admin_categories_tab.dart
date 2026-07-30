import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/image_crop_helper.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../../../home/data/models/category_model.dart';
import '../../view_model/admin_categories_cubit/admin_categories_cubit.dart';

class AdminCategoriesTab extends StatelessWidget {
  const AdminCategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openCategoryForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('add_category'.tr(),
            style: const TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<AdminCategoriesCubit, AdminCategoriesState>(
        listener: (context, state) {
          if (state is AdminCategoriesFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is AdminCategoriesLoading ||
              state is AdminCategoriesInitial) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final categories = state is AdminCategoriesLoaded
              ? state.categories
              : <CategoryModel>[];
          if (categories.isEmpty) {
            return EmptyState(
                icon: Icons.category_outlined, title: 'no_categories'.tr());
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 90.h),
            itemCount: categories.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, i) =>
                _CategoryTile(category: categories[i]),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});
  final CategoryModel category;

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
              imageUrl: category.imageUrl ?? '',
              width: 52.w,
              height: 52.w,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                  color: cs.surfaceContainerHigh, width: 52.w, height: 52.w),
              errorWidget: (_, _, _) => Container(
                color: cs.surfaceContainerHigh,
                width: 52.w,
                height: 52.w,
                alignment: Alignment.center,
                child: Icon(Icons.category_outlined,
                    color: cs.onSurfaceVariant, size: 22.r),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.semiBold14),
                SizedBox(height: 2.h),
                Text('${category.productsCount ?? 0} ${'products'.tr()}',
                    style: AppStyles.regular12
                        .copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openCategoryForm(context, existing: category),
            icon: Icon(Icons.edit_outlined,
                size: 20.r, color: cs.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, category.id),
            icon: Icon(Icons.delete_outline,
                size: 20.r, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final cubit = context.read<AdminCategoriesCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_category_q'.tr()),
        content: Text('cannot_undone'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              cubit.deleteCategory(id);
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

void _openCategoryForm(BuildContext context, {CategoryModel? existing}) {
  final cubit = context.read<AdminCategoriesCubit>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _CategoryForm(existing: existing),
    ),
  );
}

class _CategoryForm extends StatefulWidget {
  const _CategoryForm({this.existing});
  final CategoryModel? existing;

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  late final _name = TextEditingController(text: widget.existing?.name);
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String? _pickedPath;
  late final String? _existingUrl = widget.existing?.imageUrl;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1000);
    if (file == null) return;

    final cropped = await ImageCropHelper.cropSquare(file.path);
    if (cropped != null) setState(() => _pickedPath = cropped);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AdminCategoriesCubit>().saveCategory(
          id: widget.existing?.id,
          name: _name.text.trim(),
          imagePath: _pickedPath,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                widget.existing == null
                    ? 'add_category'.tr()
                    : 'edit_category'.tr(),
                style: AppStyles.bold20),
            SizedBox(height: 16.h),
            CustomTextField(controller: _name, hint: 'category_name'.tr()),
            SizedBox(height: 14.h),
            _ImagePickerField(
              pickedPath: _pickedPath,
              existingUrl: _existingUrl,
              onPick: _pickImage,
            ),
            SizedBox(height: 20.h),
            BlocConsumer<AdminCategoriesCubit, AdminCategoriesState>(
              listener: (context, state) {
                if (state is AdminCategorySaved) Navigator.pop(context);
              },
              builder: (context, state) => CustomButton(
                text: 'save'.tr(),
                isLoading: state is AdminCategorySaving,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.pickedPath,
    required this.existingUrl,
    required this.onPick,
  });

  final String? pickedPath;
  final String? existingUrl;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasImage =
        pickedPath != null || (existingUrl != null && existingUrl!.isNotEmpty);
    return GestureDetector(
      onTap: onPick,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 64.w,
              height: 64.w,
              child: _thumb(cs),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('category_image'.tr(), style: AppStyles.semiBold14),
                SizedBox(height: 3.h),
                Text(
                  hasImage ? 'change_image'.tr() : 'pick_image'.tr(),
                  style: AppStyles.regular12.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Icon(Icons.image_outlined, color: cs.onSurfaceVariant, size: 22.r),
        ],
      ),
    );
  }

  Widget _thumb(ColorScheme cs) {
    if (pickedPath != null) {
      return Image.file(File(pickedPath!), fit: BoxFit.cover);
    }
    if (existingUrl != null && existingUrl!.isNotEmpty) {
      return CachedNetworkImage(imageUrl: existingUrl!, fit: BoxFit.cover);
    }
    return Container(
      color: cs.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(Icons.add_a_photo_outlined,
          color: cs.onSurfaceVariant, size: 24.r),
    );
  }
}
