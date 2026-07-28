import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/banner_model.dart';
import '../../../view_model/banners_cubit/banners_cubit.dart';
import '../../category_products_view.dart';
import '../../details_view.dart';
import 'home_shimmers.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients || _count < 2) return;
      final next = (_index + 1) % _count;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(BannerModel banner) {
    if (banner.linkType == 'product' && banner.linkValue != null) {
      push(context, DetailsView(productId: banner.linkValue!));
    } else if (banner.linkType == 'category' && banner.linkValue != null) {
      final title = (banner.title != null && banner.title!.isNotEmpty)
          ? banner.title!
          : 'products'.tr();
      push(
        context,
        CategoryProductsView(categoryId: banner.linkValue!, title: title),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannersCubit, BannersState>(
      builder: (context, state) {
        if (state is BannersLoading || state is BannersInitial) {
          return const BannerShimmer();
        }
        final banners =
            state is BannersSuccess ? state.banners : <BannerModel>[];
        if (banners.isEmpty) return const SizedBox.shrink();
        _count = banners.length;

        return Column(
          children: [
            SizedBox(
              height: 140.h,
              child: PageView.builder(
                controller: _controller,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _BannerCard(
                  banner: banners[i],
                  onTap: () => _handleTap(banners[i]),
                ),
              ),
            ),
            if (banners.length > 1) ...[
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: _index == i ? 20.w : 7.w,
                    height: 7.h,
                    decoration: BoxDecoration(
                      color: _index == i
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onTap});
  final BannerModel banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasText = (banner.title != null && banner.title!.isNotEmpty) ||
        (banner.subtitle != null && banner.subtitle!.isNotEmpty);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: banner.image,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: cs.surfaceContainerHigh),
              errorWidget: (_, _, _) =>
                  Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
            ),
            if (hasText)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            if (hasText)
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (banner.title != null && banner.title!.isNotEmpty)
                      Text(banner.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppStyles.bold24.copyWith(color: Colors.white)),
                    if (banner.subtitle != null &&
                        banner.subtitle!.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(banner.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.regular14.copyWith(
                              color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
