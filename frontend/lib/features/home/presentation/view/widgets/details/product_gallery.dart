import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({super.key, required this.images, this.heroTag});

  final List<String> images;
  final String? heroTag;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final images = widget.images.isEmpty ? [''] : widget.images;

    return Column(
      children: [
        Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final image = CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: cs.surfaceContainerHigh),
                errorWidget: (_, _, _) =>
                    Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
              );
              return (i == 0 && widget.heroTag != null)
                  ? Hero(tag: widget.heroTag!, child: image)
                  : image;
            },
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: _index == i ? 20.w : 7.w,
                height: 7.h,
                decoration: BoxDecoration(
                  color: _index == i ? AppColors.primary : cs.outlineVariant,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
