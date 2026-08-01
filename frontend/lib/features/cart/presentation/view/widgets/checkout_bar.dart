import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../checkout/presentation/view/checkout_view.dart';
import '../../../../../core/utils/spacing.dart';

class CheckoutBar extends StatelessWidget {
  const CheckoutBar({super.key, required this.subtotal, required this.count});
  final double subtotal;
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  count == 1
                      ? 'subtotal_item'.tr()
                      : 'subtotal_items'.tr(args: ['$count']),
                  style:
                      AppStyles.regular14.copyWith(color: cs.onSurfaceVariant)),
              Text(formatPrice(subtotal), style: AppStyles.bold20),
            ],
          ),
          spaceH(14),
          CustomButton(
            text: 'proceed_checkout'.tr(),
            icon: Icons.arrow_forward_rounded,
            onPressed: () => push(context, CheckoutView(subtotal: subtotal)),
          ),
        ],
      ),
    );
  }
}
