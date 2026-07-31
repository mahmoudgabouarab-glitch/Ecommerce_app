import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/styles.dart';
import '../../../data/models/genie_message.dart';
import 'genie_product_card.dart';

class GenieBubble extends StatelessWidget {
  const GenieBubble({super.key, required this.message});

  final GenieMessage message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUser = message.role == GenieRole.user;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: 280.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : cs.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
          bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
          bottomRight: Radius.circular(isUser ? 4.r : 16.r),
        ),
        border: isUser ? null : Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        message.content,
        style: AppStyles.regular14.copyWith(
          color: isUser ? Colors.white : cs.onSurface,
          height: 1.4,
        ),
      ),
    );

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const _GenieAvatar(),
              SizedBox(width: 8.w),
            ],
            Flexible(child: bubble),
          ],
        ),
        if (message.products.isNotEmpty) ...[
          SizedBox(height: 10.h),
          SizedBox(
            height: 210.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 40.w),
              itemCount: message.products.length,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (_, i) =>
                  GenieProductCard(product: message.products[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _GenieAvatar extends StatelessWidget {
  const _GenieAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFFB347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.auto_awesome, color: Colors.white, size: 18.r),
    );
  }
}
