import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/utils/spacing.dart';

class SettingsHeaderCard extends StatelessWidget {
  const SettingsHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.avatar,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String? avatar;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.brandGradient),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(name: name, avatar: avatar),
            spaceW(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppStyles.bold20.copyWith(color: Colors.white)),
                  spaceH(4),
                  Text(email,
                      style: AppStyles.regular14.copyWith(
                          color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            Icon(Icons.edit_outlined,
                color: Colors.white.withValues(alpha: 0.9), size: 22.r),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.avatar});
  final String name;
  final String? avatar;

  @override
  Widget build(BuildContext context) {
    final hasImage = avatar != null && avatar!.isNotEmpty;
    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.25),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: avatar!,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _initial(),
            )
          : _initial(),
    );
  }

  Widget _initial() => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
}
