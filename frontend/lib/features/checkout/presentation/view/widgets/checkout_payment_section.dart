import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/styles.dart';
import '../../view_model/checkout_cubit/checkout_cubit.dart';
import 'checkout_section_title.dart';

class CheckoutPaymentSection extends StatelessWidget {
  const CheckoutPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckoutSectionTitle(
                icon: Icons.payment_outlined, text: 'payment_method'.tr()),
            SizedBox(height: 12.h),
            _PaymentTile(
              title: 'cash_on_delivery'.tr(),
              icon: Icons.local_shipping_outlined,
              value: 'cash',
              group: cubit.paymentMethod,
              onTap: () => cubit.setPaymentMethod('cash'),
            ),
            _PaymentTile(
              title: 'credit_card'.tr(),
              icon: Icons.credit_card,
              value: 'card',
              group: cubit.paymentMethod,
              onTap: () => cubit.setPaymentMethod('card'),
            ),
          ],
        );
      },
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.group,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String value;
  final String group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selected = value == group;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary.withValues(alpha: 0.08) : cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : cs.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : cs.onSurfaceVariant),
            SizedBox(width: 12.w),
            Text(title, style: AppStyles.medium14),
            const Spacer(),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
