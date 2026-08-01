import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../data/models/address_model.dart';
import '../../../view_model/address_cubit/address_cubit.dart';
import 'address_form.dart';
import '../../../../../../core/utils/spacing.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address});
  final AddressModel address;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: AppColors.primary),
          ),
          spaceW(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.fullName, style: AppStyles.semiBold14),
                    if (address.isDefault) ...[
                      spaceW(8),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text('default_label'.tr(),
                            style: AppStyles.regular12
                                .copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
                spaceH(4),
                Text('${address.line1}, ${address.city}',
                    style: AppStyles.regular12
                        .copyWith(color: cs.onSurfaceVariant)),
                Text(address.phone,
                    style: AppStyles.regular12
                        .copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => openAddressForm(context, existing: address),
            icon: Icon(Icons.edit_outlined,
                size: 20.r, color: cs.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () => context.read<AddressCubit>().delete(address.id),
            icon: Icon(Icons.delete_outline,
                size: 20.r, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
