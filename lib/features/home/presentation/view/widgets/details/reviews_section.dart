import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../auth/presentation/view/widgets/login_required.dart';
import '../../../../data/models/review_model.dart';
import '../../../view_model/reviews_cubit/reviews_cubit.dart';

/// Reviews list + "Write a review" action for the product details page.
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsCubit, ReviewsState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          showSnackBar(context, 'thanks_review'.tr(), success: true);
        } else if (state is ReviewsFailure) {
          showSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('reviews'.tr(), style: AppStyles.semiBold16),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _openDialog(context),
                  icon: Icon(Icons.rate_review_outlined,
                      size: 18.r, color: AppColors.primary),
                  label: Text('write_review'.tr(),
                      style: AppStyles.semiBold14
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (state is ReviewsLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (state is ReviewsSuccess && state.reviews.isEmpty)
              Text('no_reviews'.tr(),
                  style: AppStyles.regular14
                      .copyWith(color: AppStyles.muted(context)))
            else if (state is ReviewsSuccess)
              ...state.reviews.map((r) => _ReviewTile(review: r)),
          ],
        );
      },
    );
  }

  void _openDialog(BuildContext context) {
    // Guests can browse reviews but must sign in to write one.
    if (isGuestUser()) {
      showLoginRequired(context);
      return;
    }
    final cubit = context.read<ReviewsCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _AddReviewDialog(productId: productId),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: AppStyles.semiBold14.copyWith(color: AppColors.primary),
                ),
              ),
              SizedBox(width: 10.w),
              Text(review.userName, style: AppStyles.semiBold14),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 15.r,
                    color: AppColors.star,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(review.comment,
                style: AppStyles.regular14
                    .copyWith(color: cs.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

class _AddReviewDialog extends StatefulWidget {
  const _AddReviewDialog({required this.productId});
  final int productId;

  @override
  State<_AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<_AddReviewDialog> {
  int _rating = 5;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text('write_review'.tr(), style: AppStyles.bold20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                onPressed: () => setState(() => _rating = i + 1),
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.star,
                  size: 30.r,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(hintText: 'share_thoughts'.tr()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr(),
              style: TextStyle(color: cs.onSurfaceVariant)),
        ),
        BlocConsumer<ReviewsCubit, ReviewsState>(
          listener: (context, state) {
            if (state is ReviewSubmitted) Navigator.pop(context);
          },
          builder: (context, state) => FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: state is ReviewSubmitting
                ? null
                : () => context.read<ReviewsCubit>().addReview(
                      productId: widget.productId,
                      rating: _rating,
                      comment: _controller.text.trim(),
                    ),
            child: state is ReviewSubmitting
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('submit'.tr()),
          ),
        ),
      ],
    );
  }
}
