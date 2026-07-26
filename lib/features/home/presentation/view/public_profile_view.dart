import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/models/public_profile_model.dart';
import '../../data/repo/home_repo_impl.dart';

/// Read-only profile of another user, opened by tapping their review.
class PublicProfileView extends StatefulWidget {
  const PublicProfileView({
    super.key,
    required this.userId,
    required this.userName,
  });

  final int userId;
  final String userName;

  @override
  State<PublicProfileView> createState() => _PublicProfileViewState();
}

class _PublicProfileViewState extends State<PublicProfileView> {
  late Future<Either<Failure, PublicProfileModel>> _future =
      getIt<HomeRepoImpl>().getPublicProfile(widget.userId);

  void _retry() {
    setState(() {
      _future = getIt<HomeRepoImpl>().getPublicProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('user_profile'.tr())),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          return snapshot.data!.fold(
            (failure) => ErrorState(
                message: failure.errorMessage, onRetry: _retry),
            (profile) => _ProfileContent(profile: profile),
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          CircleAvatar(
            radius: 52.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundImage:
                (profile.avatar != null && profile.avatar!.isNotEmpty)
                    ? CachedNetworkImageProvider(profile.avatar!)
                    : null,
            child: (profile.avatar == null || profile.avatar!.isEmpty)
                ? Text(
                    profile.name.isNotEmpty
                        ? profile.name[0].toUpperCase()
                        : '?',
                    style: AppStyles.bold28.copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          SizedBox(height: 16.h),
          Text(profile.name,
              style: AppStyles.bold24, textAlign: TextAlign.center),
          if (profile.memberSince != null) ...[
            SizedBox(height: 6.h),
            Text('${'member_since'.tr()} ${profile.memberSince}',
                style: AppStyles.regular14
                    .copyWith(color: cs.onSurfaceVariant)),
          ],
          SizedBox(height: 28.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined,
                    color: AppColors.primary, size: 28.r),
                SizedBox(height: 8.h),
                Text('${profile.reviewsCount}', style: AppStyles.bold24),
                SizedBox(height: 2.h),
                Text('reviews'.tr(),
                    style: AppStyles.regular14
                        .copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
