import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/product_model.dart';
import '../../../view_model/deals_cubit/deals_cubit.dart';
import '../../details_view.dart';
import 'home_shimmers.dart';
import '../../../../../../core/utils/spacing.dart';

class FlashDealsSection extends StatefulWidget {
  const FlashDealsSection({super.key});

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DealsCubit, DealsState>(
      builder: (context, state) {
        if (state is DealsLoading || state is DealsInitial) {
          return Padding(
            padding: EdgeInsets.only(bottom: 22.h),
            child: HCardsShimmer(height: 262.h, cardWidth: 160),
          );
        }
        if (state is! DealsSuccess) return const SizedBox.shrink();

        final now = DateTime.now();
        final deals = state.products
            .where((p) => p.dealEndsAt != null && p.dealEndsAt!.isAfter(now))
            .toList();
        if (deals.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🔥', style: TextStyle(fontSize: 18.sp)),
                spaceW(6),
                Text('flash_deals'.tr(), style: AppStyles.bold20),
              ],
            ),
            spaceH(14),
            SizedBox(
              height: 262.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: deals.length,
                separatorBuilder: (_, _) => spaceW(12),
                itemBuilder: (_, i) =>
                    _DealCard(product: deals[i], remaining: deals[i].dealEndsAt!.difference(now)),
              ),
            ),
            spaceH(22),
          ],
        );
      },
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.product, required this.remaining});

  final ProductModel product;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => push(context, DetailsView(productId: product.id)),
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130.h,
                  width: double.infinity,
                  color: cs.surfaceContainerHigh,
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: cs.surfaceContainerHigh),
                    errorWidget: (_, _, _) =>
                        Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
                  ),
                ),
                if (product.discountPercent > 0)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text('-${product.discountPercent}%',
                          style: AppStyles.semiBold14
                              .copyWith(color: Colors.white, fontSize: 11.sp)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.semiBold14),
                  spaceH(6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(formatPrice(product.effectivePrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.price),
                      ),
                      spaceW(6),
                      Flexible(
                        child: Text(formatPrice(product.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.regular12.copyWith(
                              color: cs.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            )),
                      ),
                    ],
                  ),
                  spaceH(8),
                  _CountdownChip(remaining: remaining),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownChip extends StatelessWidget {
  const _CountdownChip({required this.remaining});
  final Duration remaining;

  String _fmt(Duration d) {
    two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    return '${two(h)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14.r, color: AppColors.primary),
          spaceW(5),
          Text(_fmt(remaining),
              style: AppStyles.semiBold14
                  .copyWith(color: AppColors.primary, fontSize: 12.sp)),
        ],
      ),
    );
  }
}
