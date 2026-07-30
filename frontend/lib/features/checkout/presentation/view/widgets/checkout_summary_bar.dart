import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../view_model/checkout_cubit/checkout_cubit.dart';

class CheckoutSummaryBar extends StatelessWidget {
  const CheckoutSummaryBar({
    super.key,
    required this.subtotal,
    required this.isLoading,
  });

  final double subtotal;
  final bool isLoading;

  static const double shippingFee = 50;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        final discount = context.read<CheckoutCubit>().discount;
        final total = subtotal - discount + shippingFee;
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: Column(
            children: [
              _row(context, 'subtotal'.tr(), subtotal),
              if (discount > 0) ...[
                SizedBox(height: 6.h),
                _row(context, 'discount'.tr(), -discount,
                    valueColor: AppColors.success),
              ],
              SizedBox(height: 6.h),
              _row(context, 'shipping'.tr(), shippingFee),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Divider(color: cs.outlineVariant, height: 1),
              ),
              _row(context, 'total'.tr(), total, bold: true),
              SizedBox(height: 14.h),
              CustomButton(
                text: 'place_order'.tr(),
                isLoading: isLoading,
                onPressed: () => context.read<CheckoutCubit>().placeOrder(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(BuildContext context, String label, double value,
      {bool bold = false, Color? valueColor}) {
    final cs = Theme.of(context).colorScheme;
    final prefix = value < 0 ? '- ' : '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? AppStyles.semiBold16
                : AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
        Text('$prefix${formatPrice(value.abs())}',
            style: bold
                ? AppStyles.bold20.copyWith(color: AppColors.primary)
                : AppStyles.medium14.copyWith(color: valueColor)),
      ],
    );
  }
}
