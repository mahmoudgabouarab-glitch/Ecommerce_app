import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/network/cache_helper.dart';
import '../../../../../../core/network/cache_keys.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../view_model/edit_profile_cubit/edit_profile_cubit.dart';
import 'avatar_picker.dart';
import 'birth_date_field.dart';
import 'gender_selector.dart';
import 'show_phone_switch.dart';
import '../../../../../../core/utils/spacing.dart';

class EditProfileBody extends StatelessWidget {
  const EditProfileBody({super.key});

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
                spaceH(10),
                Center(child: AvatarPicker(cubit: cubit, fallbackLetter: name)),
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
                spaceH(16),
                _label(context, 'name'.tr()),
                CustomTextField(
                    controller: cubit.nameController,
                    hint: 'name'.tr(),
                    icon: Icons.person_outline),
                spaceH(16),
                _label(context, 'phone'.tr()),
                CustomTextField(
                  controller: cubit.phoneController,
                  hint: 'phone'.tr(),
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (_) => null,
                ),
                spaceH(8),
                ShowPhoneSwitch(cubit: cubit),
                spaceH(8),
                _label(context, 'gender'.tr()),
                GenderSelector(cubit: cubit),
                spaceH(16),
                _label(context, 'birth_date'.tr()),
                BirthDateField(cubit: cubit),
                spaceH(16),
                _label(context, 'bio'.tr()),
                CustomTextField(
                  controller: cubit.bioController,
                  hint: 'bio_hint'.tr(),
                  icon: Icons.info_outline,
                  validator: (_) => null,
                ),
                spaceH(32),
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
