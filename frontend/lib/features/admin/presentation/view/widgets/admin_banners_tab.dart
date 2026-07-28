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
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../../../home/data/models/banner_model.dart';
import '../../../../home/data/models/category_model.dart';
import '../../../../home/data/models/product_model.dart';
import '../../../../home/data/repo/home_repo_impl.dart';
import '../../view_model/admin_banners_cubit/admin_banners_cubit.dart';

class AdminBannersTab extends StatelessWidget {
  const AdminBannersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openBannerForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('add_banner'.tr(),
            style: const TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<AdminBannersCubit, AdminBannersState>(
        listener: (context, state) {
          if (state is AdminBannersFailure) showSnackBar(context, state.error);
        },
        builder: (context, state) {
          if (state is AdminBannersLoading || state is AdminBannersInitial) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final banners =
              state is AdminBannersLoaded ? state.banners : <BannerModel>[];
          if (banners.isEmpty) {
            return EmptyState(
                icon: Icons.view_carousel_outlined, title: 'no_banners'.tr());
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 90.h),
            itemCount: banners.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, i) => _BannerTile(banner: banners[i]),
          );
        },
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({required this.banner});
  final BannerModel banner;

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
              imageUrl: banner.image,
              width: 84.w,
              height: 54.w,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                  color: cs.surfaceContainerHigh, width: 84.w, height: 54.w),
              errorWidget: (_, _, _) => Container(
                color: cs.surfaceContainerHigh,
                width: 84.w,
                height: 54.w,
                alignment: Alignment.center,
                child: Icon(Icons.image_outlined,
                    color: cs.onSurfaceVariant, size: 20.r),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        (banner.title == null || banner.title!.isEmpty)
                            ? 'banner'.tr()
                            : banner.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.semiBold14,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _StatusChip(active: banner.isActive),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(banner.linkType == 'none' ? '—' : banner.linkType,
                    style: AppStyles.regular12
                        .copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openBannerForm(context, existing: banner),
            icon: Icon(Icons.edit_outlined,
                size: 20.r, color: cs.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, banner.id),
            icon: Icon(Icons.delete_outline, size: 20.r, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final cubit = context.read<AdminBannersCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_banner_q'.tr()),
        content: Text('cannot_undone'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              cubit.deleteBanner(id);
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.danger;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(active ? 'active'.tr() : 'inactive'.tr(),
          style: AppStyles.regular12.copyWith(color: color)),
    );
  }
}

void _openBannerForm(BuildContext context, {BannerModel? existing}) {
  final cubit = context.read<AdminBannersCubit>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _BannerForm(existing: existing),
    ),
  );
}

class _BannerForm extends StatefulWidget {
  const _BannerForm({this.existing});
  final BannerModel? existing;

  @override
  State<_BannerForm> createState() => _BannerFormState();
}

class _BannerFormState extends State<_BannerForm> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _subtitle = TextEditingController(text: widget.existing?.subtitle);
  final _picker = ImagePicker();

  String? _pickedPath;
  late final String? _existingUrl = widget.existing?.image;
  late String _linkType = widget.existing?.linkType ?? 'none';
  late int? _linkValue = widget.existing?.linkValue;
  late bool _active = widget.existing?.isActive ?? true;

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _loadLinkTargets();
  }

  Future<void> _loadLinkTargets() async {
    final repo = getIt<HomeRepoImpl>();
    final cats = await repo.getCategories();
    final prods = await repo.getProducts(perPage: 100);
    if (!mounted) return;
    setState(() {
      cats.fold((_) {}, (r) => _categories = r.data);
      prods.fold((_) {}, (r) => _products = r.data);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
    if (file != null) setState(() => _pickedPath = file.path);
  }

  void _submit() {
    if (_pickedPath == null &&
        (_existingUrl == null || _existingUrl.isEmpty)) {
      showSnackBar(context, 'pick_image'.tr());
      return;
    }
    context.read<AdminBannersCubit>().saveBanner(
          id: widget.existing?.id,
          title: _title.text.trim(),
          subtitle: _subtitle.text.trim(),
          linkType: _linkType,
          linkValue: _linkType == 'none' ? null : _linkValue,
          isActive: _active,
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                widget.existing == null
                    ? 'add_banner'.tr()
                    : 'edit_banner'.tr(),
                style: AppStyles.bold20),
            SizedBox(height: 16.h),
            _ImagePickerField(
              pickedPath: _pickedPath,
              existingUrl: _existingUrl,
              onPick: _pickImage,
            ),
            SizedBox(height: 14.h),
            CustomTextField(
                controller: _title,
                hint: 'banner_title'.tr(),
                validator: (_) => null),
            SizedBox(height: 12.h),
            CustomTextField(
                controller: _subtitle,
                hint: 'banner_subtitle'.tr(),
                validator: (_) => null),
            SizedBox(height: 14.h),
            Text('banner_link'.tr(), style: AppStyles.semiBold14),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _linkType,
              decoration: const InputDecoration(),
              items: [
                DropdownMenuItem(value: 'none', child: Text('link_none'.tr())),
                DropdownMenuItem(
                    value: 'category', child: Text('link_category'.tr())),
                DropdownMenuItem(
                    value: 'product', child: Text('link_product'.tr())),
              ],
              onChanged: (v) => setState(() {
                _linkType = v ?? 'none';
                _linkValue = null;
              }),
            ),
            if (_linkType == 'category') ...[
              SizedBox(height: 12.h),
              DropdownButtonFormField<int>(
                initialValue: _valueIfPresent(_categories.map((c) => c.id)),
                decoration:
                    InputDecoration(hintText: 'select_category'.tr()),
                items: _categories
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _linkValue = v),
              ),
            ],
            if (_linkType == 'product') ...[
              SizedBox(height: 12.h),
              DropdownButtonFormField<int>(
                initialValue: _valueIfPresent(_products.map((p) => p.id)),
                decoration: InputDecoration(hintText: 'select_product'.tr()),
                items: _products
                    .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.title, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _linkValue = v),
              ),
            ],
            SwitchListTile(
              value: _active,
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Text('active'.tr(), style: AppStyles.medium14),
              onChanged: (v) => setState(() => _active = v),
            ),
            SizedBox(height: 8.h),
            BlocConsumer<AdminBannersCubit, AdminBannersState>(
              listener: (context, state) {
                if (state is AdminBannerSaved) Navigator.pop(context);
              },
              builder: (context, state) => CustomButton(
                text: 'save'.tr(),
                isLoading: state is AdminBannerSaving,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? _valueIfPresent(Iterable<int> ids) =>
      ids.contains(_linkValue) ? _linkValue : null;
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
    return GestureDetector(
      onTap: onPick,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: SizedBox(
          height: 120.h,
          width: double.infinity,
          child: _thumb(cs),
        ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined,
              color: cs.onSurfaceVariant, size: 26.r),
          SizedBox(height: 6.h),
          Text('pick_image'.tr(),
              style:
                  AppStyles.regular12.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
