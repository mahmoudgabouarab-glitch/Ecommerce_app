import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../order/presentation/view/order_details_view.dart';
import '../../view_model/checkout_cubit/checkout_cubit.dart';

class CheckoutBody extends StatelessWidget {
  const CheckoutBody({super.key, required this.subtotal});

  final double subtotal;
  static const double shippingFee = 50;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();

    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          showSnackBar(context, 'order_placed'.tr(args: ['${state.order.id}']),
              success: true);
          // Go straight to the new order's details (back returns to home).
          pushAndKeepFirst(context, OrderDetailsView(order: state.order));
        } else if (state is CheckoutFailure) {
          showSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(icon: Icons.location_on_outlined, text: 'shipping_address'.tr()),
                      SizedBox(height: 14.h),
                      const _AddressSection(),
                      SizedBox(height: 24.h),
                      _SectionTitle(icon: Icons.payment_outlined, text: 'payment_method'.tr()),
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
                      SizedBox(height: 24.h),
                      _SectionTitle(icon: Icons.local_offer_outlined, text: 'coupon'.tr()),
                      SizedBox(height: 12.h),
                      const _CouponField(),
                    ],
                  ),
                ),
              ),
            ),
            _SummaryBar(subtotal: subtotal, isLoading: state is CheckoutLoading),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(text, style: AppStyles.semiBold16),
      ],
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
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : cs.surface,
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

/// Shows saved addresses to pick from, plus an inline form for a new one.
class _AddressSection extends StatelessWidget {
  const _AddressSection();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saved address cards
            ...cubit.addresses.map((a) {
              final selected =
                  !cubit.useNewAddress && cubit.selectedAddressId == a.id;
              return GestureDetector(
                onTap: () => cubit.selectAddress(a.id),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : cs.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: selected ? AppColors.primary : cs.outline,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color:
                            selected ? AppColors.primary : cs.onSurfaceVariant,
                        size: 20.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.fullName, style: AppStyles.semiBold14),
                            Text('${a.line1}, ${a.city} • ${a.phone}',
                                style: AppStyles.regular12
                                    .copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // "Use a new address" toggle (only when saved addresses exist)
            if (cubit.addresses.isNotEmpty)
              GestureDetector(
                onTap: cubit.useNew,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(
                        cubit.useNewAddress
                            ? Icons.radio_button_checked
                            : Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text('use_new_address'.tr(),
                          style: AppStyles.semiBold14
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),

            // Inline new-address form (also shown when there are no saved ones)
            if (cubit.useNewAddress || cubit.addresses.isEmpty) ...[
              SizedBox(height: 12.h),
              CustomTextField(
                  controller: cubit.fullNameController, hint: 'full_name'.tr()),
              SizedBox(height: 12.h),
              CustomTextField(
                  controller: cubit.phoneController,
                  hint: 'phone'.tr(),
                  keyboardType: TextInputType.phone),
              SizedBox(height: 12.h),
              CustomTextField(
                  controller: cubit.line1Controller, hint: 'address_line'.tr()),
              SizedBox(height: 12.h),
              CustomTextField(
                  controller: cubit.cityController, hint: 'city'.tr()),
            ],
          ],
        );
      },
    );
  }
}

/// Coupon input with an Apply button and status feedback.
class _CouponField extends StatelessWidget {
  const _CouponField();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.subtotal, required this.isLoading});
  final double subtotal;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        final discount = context.read<CheckoutCubit>().discount;
        final total = subtotal - discount + CheckoutBody.shippingFee;
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
                _row(context, 'discount'.tr(), -discount, valueColor: AppColors.success),
              ],
              SizedBox(height: 6.h),
              _row(context, 'shipping'.tr(), CheckoutBody.shippingFee),
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
