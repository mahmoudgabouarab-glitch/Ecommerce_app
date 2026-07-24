import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/network/service_locator.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../home/data/models/category_model.dart';
import '../../../../home/data/models/product_model.dart';
import '../../../../home/data/repo/home_repo_impl.dart';
import '../../view_model/admin_products_cubit/admin_products_cubit.dart';

void openProductForm(BuildContext context, {ProductModel? existing}) {
  final cubit = context.read<AdminProductsCubit>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _ProductForm(existing: existing),
    ),
  );
}

class _ProductForm extends StatefulWidget {
  const _ProductForm({this.existing});
  final ProductModel? existing;

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _desc = TextEditingController(text: widget.existing?.description);
  late final _brand = TextEditingController(text: widget.existing?.brand);
  late final _price =
      TextEditingController(text: widget.existing?.price.toStringAsFixed(0));
  late final _sale = TextEditingController(
      text: widget.existing?.salePrice?.toStringAsFixed(0) ?? '');
  late final _stock =
      TextEditingController(text: '${widget.existing?.stock ?? ''}');
  late bool _featured = widget.existing?.isFeatured ?? false;
  int? _categoryId;
  List<CategoryModel> _categories = [];
  final _formKey = GlobalKey<FormState>();

  final _picker = ImagePicker();

  // Images: existing URLs kept + new local files picked.
  late final List<String> _existingImages =
      List<String>.from(widget.existing?.images ?? const []);
  final List<String> _newImages = [];

  // Variant rows (size / color / stock / price difference).
  final List<_VariantRow> _variants = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadVariants();
  }

  Future<void> _loadCategories() async {
    final result = await getIt<HomeRepoImpl>().getCategories();
    result.fold((_) {}, (res) {
      if (mounted) setState(() => _categories = res.data);
    });
  }

  /// The admin list endpoint doesn't include variants, so fetch the full
  /// product when editing to populate the variant rows.
  Future<void> _loadVariants() async {
    final id = widget.existing?.id;
    if (id == null) return;
    final result = await getIt<HomeRepoImpl>().getProductDetails(id);
    result.fold((_) {}, (product) {
      if (!mounted) return;
      setState(() {
        _variants
          ..clear()
          ..addAll(product.variants.map(_VariantRow.fromModel));
      });
    });
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1000);
    if (files.isNotEmpty) {
      setState(() => _newImages.addAll(files.map((f) => f.path)));
    }
  }

  @override
  void dispose() {
    for (final c in [_title, _desc, _brand, _price, _sale, _stock]) {
      c.dispose();
    }
    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  widget.existing == null
                      ? 'add_product'.tr()
                      : 'edit_product'.tr(),
                  style: AppStyles.bold20),
              SizedBox(height: 16.h),
              CustomTextField(controller: _title, hint: 'title'.tr()),
              SizedBox(height: 12.h),
              CustomTextField(
                  controller: _desc,
                  hint: 'description'.tr(),
                  validator: (_) => null),
              SizedBox(height: 12.h),
              CustomTextField(
                  controller: _brand, hint: 'brand'.tr(), validator: (_) => null),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                        controller: _price,
                        hint: 'price'.tr(),
                        keyboardType: TextInputType.number),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                        controller: _sale,
                        hint: 'sale_price'.tr(),
                        keyboardType: TextInputType.number,
                        validator: (_) => null),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                  controller: _stock,
                  hint: 'stock'.tr(),
                  keyboardType: TextInputType.number),
              SizedBox(height: 16.h),

              // --- Photos ---
              Text('product_photos'.tr(), style: AppStyles.semiBold16),
              SizedBox(height: 10.h),
              _ImagesStrip(
                existingUrls: _existingImages,
                newPaths: _newImages,
                onAdd: _pickImages,
                onRemoveExisting: (url) =>
                    setState(() => _existingImages.remove(url)),
                onRemoveNew: (path) => setState(() => _newImages.remove(path)),
              ),
              SizedBox(height: 16.h),

              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: InputDecoration(hintText: 'category'.tr()),
                dropdownColor: cs.surface,
                items: _categories
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              SizedBox(height: 4.h),
              SwitchListTile(
                value: _featured,
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                title: Text('featured'.tr(), style: AppStyles.medium14),
                onChanged: (v) => setState(() => _featured = v),
              ),
              SizedBox(height: 8.h),

              // --- Variants ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('variants'.tr(), style: AppStyles.semiBold16),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _variants.add(_VariantRow())),
                    icon: Icon(Icons.add, size: 18.r, color: AppColors.primary),
                    label: Text('add_variant'.tr(),
                        style: AppStyles.medium14
                            .copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
              ..._variants.map((row) => _VariantEditor(
                    key: ObjectKey(row),
                    row: row,
                    onRemove: () => setState(() {
                      _variants.remove(row);
                      row.dispose();
                    }),
                  )),
              SizedBox(height: 16.h),

              BlocConsumer<AdminProductsCubit, AdminProductsState>(
                listener: (context, state) {
                  if (state is AdminProductSaved) Navigator.pop(context);
                },
                builder: (context, state) => CustomButton(
                  text: 'save'.tr(),
                  isLoading: state is AdminProductSaving,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Keep only variant rows that actually describe an option.
    final variants = _variants
        .map((r) => r.toModel())
        .where((v) =>
            (v.size?.isNotEmpty ?? false) || (v.color?.isNotEmpty ?? false))
        .toList();

    context.read<AdminProductsCubit>().saveProduct(
          id: widget.existing?.id,
          title: _title.text.trim(),
          description: _desc.text.trim(),
          brand: _brand.text.trim(),
          price: double.tryParse(_price.text.trim()) ?? 0,
          salePrice: _sale.text.trim().isEmpty
              ? null
              : double.tryParse(_sale.text.trim()),
          stock: int.tryParse(_stock.text.trim()) ?? 0,
          categoryId: _categoryId,
          newImagePaths: _newImages,
          keepImageUrls: _existingImages,
          variants: variants,
          isFeatured: _featured,
        );
  }
}

/// Horizontal strip of image thumbnails (existing + newly picked) with a
/// trailing "add" tile.
class _ImagesStrip extends StatelessWidget {
  const _ImagesStrip({
    required this.existingUrls,
    required this.newPaths,
    required this.onAdd,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  final List<String> existingUrls;
  final List<String> newPaths;
  final VoidCallback onAdd;
  final void Function(String url) onRemoveExisting;
  final void Function(String path) onRemoveNew;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 100.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final url in existingUrls)
            _thumb(
              cs,
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
              onRemove: () => onRemoveExisting(url),
            ),
          for (final path in newPaths)
            _thumb(
              cs,
              child: Image.file(File(path), fit: BoxFit.cover),
              onRemove: () => onRemoveNew(path),
            ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: cs.onSurfaceVariant, size: 26.r),
                  SizedBox(height: 4.h),
                  Text('add'.tr(),
                      style: AppStyles.regular12
                          .copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(ColorScheme cs,
      {required Widget child, required VoidCallback onRemove}) {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: Stack(
        children: [
          Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(3.r),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: Icon(Icons.close, color: Colors.white, size: 14.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One editable variant row.
class _VariantEditor extends StatelessWidget {
  const _VariantEditor({super.key, required this.row, required this.onRemove});
  final _VariantRow row;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomTextField(
                controller: row.size,
                hint: 'size'.tr(),
                validator: (_) => null),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: CustomTextField(
                controller: row.color,
                hint: 'color'.tr(),
                validator: (_) => null),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: CustomTextField(
                controller: row.stock,
                hint: 'stock'.tr(),
                keyboardType: TextInputType.number,
                validator: (_) => null),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: CustomTextField(
                controller: row.price,
                hint: 'price_diff'.tr(),
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                validator: (_) => null),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.remove_circle_outline,
                color: AppColors.danger, size: 22.r),
          ),
        ],
      ),
    );
  }
}

/// Holds the editing controllers for a single variant.
class _VariantRow {
  _VariantRow({
    this.id = 0,
    String? size,
    String? color,
    int stock = 0,
    double priceDiff = 0,
  })  : size = TextEditingController(text: size ?? ''),
        color = TextEditingController(text: color ?? ''),
        stock = TextEditingController(text: stock == 0 ? '' : '$stock'),
        price = TextEditingController(
            text: priceDiff == 0 ? '' : priceDiff.toStringAsFixed(0));

  factory _VariantRow.fromModel(ProductVariantModel v) => _VariantRow(
        id: v.id,
        size: v.size,
        color: v.color,
        stock: v.stock,
        priceDiff: v.priceDiff,
      );

  final int id; // 0 = new variant
  final TextEditingController size;
  final TextEditingController color;
  final TextEditingController stock;
  final TextEditingController price;

  ProductVariantModel toModel() => ProductVariantModel(
        id: id,
        size: size.text.trim().isEmpty ? null : size.text.trim(),
        color: color.text.trim().isEmpty ? null : color.text.trim(),
        stock: int.tryParse(stock.text.trim()) ?? 0,
        priceDiff: double.tryParse(price.text.trim()) ?? 0,
      );

  void dispose() {
    size.dispose();
    color.dispose();
    stock.dispose();
    price.dispose();
  }
}
