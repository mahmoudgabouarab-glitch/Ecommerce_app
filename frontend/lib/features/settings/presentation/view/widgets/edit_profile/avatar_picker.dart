import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../view_model/edit_profile_cubit/edit_profile_cubit.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.cubit,
    required this.fallbackLetter,
  });
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
