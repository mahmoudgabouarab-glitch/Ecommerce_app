import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../main_layout.dart';
import '../../view_model/checkout_cubit/checkout_cubit.dart';
import '../payment_web_view.dart';
import 'checkout_address_section.dart';
import 'checkout_coupon_section.dart';
import 'checkout_payment_section.dart';
import 'checkout_summary_bar.dart';

class CheckoutBody extends StatelessWidget {
  const CheckoutBody({super.key, required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();

    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          showSnackBar(context, 'order_placed'.tr(args: ['${state.order.id}']),
              success: true);
          pushAndRemoveUntil(context, const MainLayout(initialIndex: 2));
        } else if (state is CheckoutCardPayment) {
          _startCardPayment(context, state);
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
                      const CheckoutAddressSection(),
                      SizedBox(height: 24.h),
                      const CheckoutPaymentSection(),
                      SizedBox(height: 24.h),
                      const CheckoutCouponSection(),
                    ],
                  ),
                ),
              ),
            ),
            CheckoutSummaryBar(
                subtotal: subtotal, isLoading: state is CheckoutLoading),
          ],
        );
      },
    );
  }
}

Future<void> _startCardPayment(
    BuildContext context, CheckoutCardPayment state) async {
  final cubit = context.read<CheckoutCubit>();

  await push<bool>(context, PaymentWebView(iframeUrl: state.iframeUrl));
  if (!context.mounted) return;

  showSnackBar(context, 'confirming_payment'.tr());
  final paid = await cubit.confirmCardPayment(state.order.id);
  if (!context.mounted) return;

  if (paid) {
    showSnackBar(context, 'payment_success'.tr(args: ['${state.order.id}']),
        success: true);
  } else {
    showSnackBar(context, 'payment_pending'.tr());
  }
  pushAndRemoveUntil(context, const MainLayout(initialIndex: 2));
}
