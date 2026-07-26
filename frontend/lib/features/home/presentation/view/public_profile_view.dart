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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          return snapshot.data!.fold(
            (failure) => Padding(
              padding: EdgeInsets.only(top: 80.h),
              child: ErrorState(message: failure.errorMessage, onRetry: _retry),
            ),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(profile: profile),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsRow(profile: profile),
                if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
                  SizedBox(height: 22.h),
                  _SectionLabel('bio'.tr()),
                  SizedBox(height: 10.h),
                  _BioCard(bio: profile.bio!.trim()),
                ],
                SizedBox(height: 22.h),
                _SectionLabel('details'.tr()),
                SizedBox(height: 10.h),
                _DetailsCard(profile: profile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topInset + 56.h, bottom: 30.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              backgroundImage:
                  (profile.avatar != null && profile.avatar!.isNotEmpty)
                      ? CachedNetworkImageProvider(profile.avatar!)
                      : null,
              child: (profile.avatar == null || profile.avatar!.isEmpty)
                  ? Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style:
                          AppStyles.bold28.copyWith(color: Colors.white),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 14.h),
          Text(profile.name,
              style: AppStyles.bold24.copyWith(color: Colors.white),
              textAlign: TextAlign.center),
          if (profile.memberSince != null) ...[
            SizedBox(height: 6.h),
            Text('${'member_since'.tr()} ${profile.memberSince}',
                style: AppStyles.regular14
                    .copyWith(color: Colors.white.withValues(alpha: 0.85))),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return _StatTile(
      icon: Icons.rate_review_outlined,
      value: '${profile.reviewsCount}',
      label: 'reviews'.tr(),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22.r),
          ),
          SizedBox(width: 14.w),
          Text(value, style: AppStyles.bold24),
          SizedBox(width: 8.w),
          Text(label,
              style:
                  AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _BioCard extends StatelessWidget {
  const _BioCard({required this.bio});
  final String bio;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(bio,
          style: AppStyles.regular14.copyWith(color: cs.onSurface, height: 1.5)),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gender = profile.gender;
    final rows = <Widget>[
      if (gender != null && gender.isNotEmpty)
        _DetailRow(
          icon: gender == 'female' ? Icons.female : Icons.male,
          label: 'gender'.tr(),
          value: gender == 'male'
              ? 'male'.tr()
              : gender == 'female'
                  ? 'female'.tr()
                  : gender,
        ),
      if (profile.birthDate != null && profile.birthDate!.isNotEmpty)
        _DetailRow(
          icon: Icons.cake_outlined,
          label: 'birth_date'.tr(),
          value: profile.birthDate!,
        ),
      if (profile.phone != null && profile.phone!.isNotEmpty)
        _DetailRow(
          icon: Icons.phone_outlined,
          label: 'phone'.tr(),
          value: profile.phone!,
        ),
    ];

    if (rows.isEmpty) {
      return _BioCard(bio: 'no_details'.tr());
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              Divider(height: 1, color: cs.outlineVariant, indent: 56.w),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, size: 22.r, color: AppColors.primary),
          SizedBox(width: 14.w),
          Text(label,
              style:
                  AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
          const Spacer(),
          Flexible(
            child: Text(value,
                style: AppStyles.semiBold14,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppStyles.semiBold16);
}
