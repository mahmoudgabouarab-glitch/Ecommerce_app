import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../view_model/checkout_cubit/checkout_cubit.dart';
import 'checkout_section_title.dart';
import '../../../../../core/utils/spacing.dart';

class CheckoutAddressSection extends StatelessWidget {
  const CheckoutAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckoutSectionTitle(
                icon: Icons.location_on_outlined,
                text: 'shipping_address'.tr()),
            spaceH(14),
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
                      spaceW(12),
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
                      spaceW(8),
                      Text('use_new_address'.tr(),
                          style: AppStyles.semiBold14
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            if (cubit.useNewAddress || cubit.addresses.isEmpty) ...[
              spaceH(12),
              CustomTextField(
                  controller: cubit.fullNameController, hint: 'full_name'.tr()),
              spaceH(12),
              CustomTextField(
                  controller: cubit.phoneController,
                  hint: 'phone'.tr(),
                  keyboardType: TextInputType.phone),
              spaceH(12),
              CustomTextField(
                  controller: cubit.line1Controller, hint: 'address_line'.tr()),
              spaceH(12),
              CustomTextField(
                  controller: cubit.cityController, hint: 'city'.tr()),
            ],
          ],
        );
      },
    );
  }
}
