import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/cache_helper.dart';
import '../../../../core/network/cache_keys.dart';
import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/repo/profile_repo_impl.dart';
import '../view_model/edit_profile_cubit/edit_profile_cubit.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileCubit(
        getIt<ProfileRepoImpl>(),
        name: CacheHelper.getDataString(key: CacheKeys.userName),
        phone: CacheHelper.getDataString(key: CacheKeys.userPhone),
        showPhone: CacheHelper.getData(key: CacheKeys.userShowPhone) == true,
        gender: _nullIfEmpty(CacheHelper.getDataString(key: CacheKeys.userGender)),
        birthDate:
            _nullIfEmpty(CacheHelper.getDataString(key: CacheKeys.userBirthDate)),
        bio: CacheHelper.getDataString(key: CacheKeys.userBio),
        avatarUrl: CacheHelper.getDataString(key: CacheKeys.userAvatar),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('edit_profile'.tr())),
        body: const SafeArea(child: _EditProfileBody()),
      ),
    );
  }

  static String? _nullIfEmpty(String? v) => (v == null || v.isEmpty) ? null : v;
}

class _EditProfileBody extends StatelessWidget {
  const _EditProfileBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    final name = CacheHelper.getDataString(key: CacheKeys.userName) ?? '';

    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileSuccess) {
          showSnackBar(context, 'profile_updated'.tr(), success: true);
          Navigator.pop(context, true);
        } else if (state is EditProfileFailure) {
          showSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: cubit.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Center(child: _AvatarPicker(cubit: cubit, fallbackLetter: name)),
                Center(
                  child: TextButton.icon(
                    onPressed: cubit.pickImage,
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.primary),
                    label: Text('change_photo'.tr(),
                        style: AppStyles.semiBold14
                            .copyWith(color: AppColors.primary)),
                  ),
                ),
                SizedBox(height: 16.h),
                _label(context, 'name'.tr()),
                CustomTextField(
                    controller: cubit.nameController,
                    hint: 'name'.tr(),
                    icon: Icons.person_outline),
                SizedBox(height: 16.h),
                _label(context, 'phone'.tr()),
                CustomTextField(
                  controller: cubit.phoneController,
                  hint: 'phone'.tr(),
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (_) => null,
                ),
                SizedBox(height: 8.h),
                _ShowPhoneSwitch(cubit: cubit),
                SizedBox(height: 8.h),
                _label(context, 'gender'.tr()),
                _GenderSelector(cubit: cubit),
                SizedBox(height: 16.h),
                _label(context, 'birth_date'.tr()),
                _BirthDateField(cubit: cubit),
                SizedBox(height: 16.h),
                _label(context, 'bio'.tr()),
                CustomTextField(
                  controller: cubit.bioController,
                  hint: 'bio_hint'.tr(),
                  icon: Icons.info_outline,
                  validator: (_) => null,
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: 'save_changes'.tr(),
                  isLoading: state is EditProfileSaving,
                  onPressed: cubit.save,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
        child: Text(text,
            style: AppStyles.semiBold14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _ShowPhoneSwitch extends StatelessWidget {
  const _ShowPhoneSwitch({required this.cubit});
  final EditProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: SwitchListTile(
        value: cubit.showPhone,
        activeThumbColor: AppColors.primary,
        contentPadding: EdgeInsets.zero,
        title: Text('show_phone'.tr(), style: AppStyles.semiBold14),
        subtitle: Text('show_phone_desc'.tr(),
            style: AppStyles.regular12.copyWith(color: cs.onSurfaceVariant)),
        onChanged: cubit.setShowPhone,
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.cubit});
  final EditProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    const options = {'male': Icons.male, 'female': Icons.female};
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: options.entries.map((e) {
        final selected = cubit.gender == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => cubit.setGender(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: AppColors.brandGradient)
                    : null,
                color: selected ? null : cs.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: selected ? Colors.transparent : cs.outline),
              ),
              child: Column(
                children: [
                  Icon(e.value,
                      color: selected ? Colors.white : cs.onSurfaceVariant,
                      size: 22.r),
                  SizedBox(height: 4.h),
                  Text(e.key.tr(),
                      style: AppStyles.regular12.copyWith(
                          color:
                              selected ? Colors.white : cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({required this.cubit});
  final EditProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = cubit.birthDate;

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final initial = value != null
            ? DateTime.tryParse(value) ?? DateTime(now.year - 20)
            : DateTime(now.year - 20);
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1940),
          lastDate: now,
        );
        if (picked != null) cubit.setBirthDate(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: cs.onSurfaceVariant, size: 21.r),
            SizedBox(width: 12.w),
            Text(
              value ?? 'select_date'.tr(),
              style: AppStyles.medium14.copyWith(
                color: value != null ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.cubit, required this.fallbackLetter});
  final EditProfileCubit cubit;
  final String fallbackLetter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cubit.pickImage,
      child: Stack(
        children: [
          Container(
            width: 110.r,
            height: 110.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: AppColors.brandGradient),
            ),
            padding: EdgeInsets.all(3.r),
            child: ClipOval(child: _image(context)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(7.r),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor, width: 2),
              ),
              child: Icon(Icons.edit, color: Colors.white, size: 16.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (cubit.pickedPath != null) {
      return Image.file(File(cubit.pickedPath!), fit: BoxFit.cover);
    }
    final url = cubit.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover);
    }
    return Container(
      color: cs.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Text(
        fallbackLetter.isNotEmpty ? fallbackLetter[0].toUpperCase() : '?',
        style: TextStyle(
            fontSize: 40.sp, fontWeight: FontWeight.w800, color: cs.onSurface),
      ),
    );
  }
}
