import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';

class SignupAvatarPicker extends StatelessWidget {
  const SignupAvatarPicker({super.key, required this.path, required this.onTap});

  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 100.r,
            height: 100.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: AppColors.brandGradient),
            ),
            padding: EdgeInsets.all(3.r),
            child: ClipOval(
              child: path != null
                  ? Image.file(File(path!), fit: BoxFit.cover)
                  : Container(
                      color: cs.surfaceContainerHigh,
                      alignment: Alignment.center,
                      child: Icon(Icons.person_outline,
                          size: 44.r, color: cs.onSurfaceVariant),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor, width: 2),
              ),
              child: Icon(Icons.add_a_photo_outlined,
                  color: Colors.white, size: 15.r),
            ),
          ),
        ],
      ),
    );
  }
}
