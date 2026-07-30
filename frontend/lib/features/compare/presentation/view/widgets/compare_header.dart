import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../home/data/models/product_model.dart';
import '../../../../home/presentation/view/details_view.dart';
import '../../view_model/compare_cubit/compare_cubit.dart';

class CompareHeader extends StatelessWidget {
  const CompareHeader({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: products
          .map((p) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: _card(context, p),
                ),
              ))
          .toList(),
    );
  }

  Widget _card(BuildContext context, ProductModel p) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => push(context, DetailsView(productId: p.id)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: CachedNetworkImage(
                      imageUrl: p.image,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: cs.surfaceContainerHigh),
                      errorWidget: (_, _, _) => Container(
                        color: cs.surfaceContainerHigh,
                        child: Icon(Icons.image_outlined,
                            color: cs.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 6.h,
                end: 6.w,
                child: GestureDetector(
                  onTap: () => context.read<CompareCubit>().remove(p.id),
                  child: CircleAvatar(
                    radius: 13.r,
                    backgroundColor: cs.surface.withValues(alpha: 0.92),
                    child: Icon(Icons.close_rounded,
                        size: 16.r, color: cs.onSurface),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          p.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppStyles.semiBold14,
        ),
      ],
    );
  }
}
