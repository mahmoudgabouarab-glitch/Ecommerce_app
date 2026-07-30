import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../view_model/checkout_cubit/checkout_cubit.dart';
import 'checkout_section_title.dart';

class CheckoutCouponSection extends StatelessWidget {
  const CheckoutCouponSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckoutSectionTitle(
                icon: Icons.local_offer_outlined, text: 'coupon'.tr()),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: cubit.couponController,
                    hint: 'coupon_code'.tr(),
                    validator: (_) => null,
                  ),
                ),
                SizedBox(width: 10.w),
                SizedBox(
                  height: 54.h,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                    ),
                    onPressed: state is CouponLoading ? null : cubit.applyCoupon,
                    child: state is CouponLoading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('apply'.tr()),
                  ),
                ),
              ],
            ),
            if (cubit.discount > 0) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 16),
                  SizedBox(width: 6.w),
                  Text('coupon_applied'.tr(args: [formatPrice(cubit.discount)]),
                      style: AppStyles.regular12
                          .copyWith(color: AppColors.success)),
                ],
              ),
            ] else if (state is CouponInvalid) ...[
              SizedBox(height: 8.h),
              Text(state.message,
                  style: AppStyles.regular12.copyWith(color: AppColors.danger)),
            ],
          ],
        );
      },
    );
  }
}
