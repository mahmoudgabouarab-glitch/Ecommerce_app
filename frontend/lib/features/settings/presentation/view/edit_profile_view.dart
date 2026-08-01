import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/cache_helper.dart';
import '../../../../core/network/cache_keys.dart';
import '../../../../core/network/service_locator.dart';
import '../../data/repo/profile_repo_impl.dart';
import '../view_model/edit_profile_cubit/edit_profile_cubit.dart';
import 'widgets/edit_profile/edit_profile_body.dart';

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
        body: const SafeArea(child: EditProfileBody()),
      ),
    );
  }

  static String? _nullIfEmpty(String? v) => (v == null || v.isEmpty) ? null : v;
}
