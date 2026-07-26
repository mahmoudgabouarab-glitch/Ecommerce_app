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
import '../../../../../core/widgets/state_views.dart';
import '../../../data/models/coupon_model.dart';
import '../../view_model/admin_coupons_cubit/admin_coupons_cubit.dart';

class AdminCouponsTab extends StatelessWidget {
  const AdminCouponsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openCouponForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('add_coupon'.tr(),
            style: const TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<AdminCouponsCubit, AdminCouponsState>(
        listener: (context, state) {
          if (state is AdminCouponsFailure) showSnackBar(context, state.error);
        },
        builder: (context, state) {
          if (state is AdminCouponsLoading || state is AdminCouponsInitial) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final coupons =
              state is AdminCouponsLoaded ? state.coupons : <CouponModel>[];
          if (coupons.isEmpty) {
            return EmptyState(
                icon: Icons.local_offer_outlined, title: 'no_coupons'.tr());
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 90.h),
            itemCount: coupons.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, i) => _CouponTile(coupon: coupons[i]),
          );
        },
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({required this.coupon});
  final CouponModel coupon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = coupon.isPercent
        ? '${coupon.amount.toStringAsFixed(0)}%'
        : formatPrice(coupon.amount);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.local_offer, color: AppColors.primary, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(coupon.code, style: AppStyles.semiBold14),
                    SizedBox(width: 8.w),
                    _StatusChip(active: coupon.isActive),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  [
                    '$value ${'off'.tr()}',
                    if (coupon.minTotal != null && coupon.minTotal! > 0)
                      '${'min_order'.tr()} ${formatPrice(coupon.minTotal!)}',
                    if (coupon.expiresAt != null)
                      '${'expires'.tr()} ${_fmtDate(coupon.expiresAt!)}',
                  ].join('  •  '),
                  style:
                      AppStyles.regular12.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, coupon.id),
            icon: Icon(Icons.delete_outline,
                size: 20.r, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _confirmDelete(BuildContext context, int id) {
    final cubit = context.read<AdminCouponsCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_coupon_q'.tr()),
        content: Text('cannot_undone'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              cubit.deleteCoupon(id);
              Navigator.pop(context);
            },
            child: Text('delete'.tr(),
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.danger;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(active ? 'active'.tr() : 'inactive'.tr(),
          style: AppStyles.regular12.copyWith(color: color)),
    );
  }
}

void _openCouponForm(BuildContext context) {
  final cubit = context.read<AdminCouponsCubit>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _CouponForm(),
    ),
  );
}

class _CouponForm extends StatefulWidget {
  const _CouponForm();

  @override
  State<_CouponForm> createState() => _CouponFormState();
}

class _CouponFormState extends State<_CouponForm> {
  final _code = TextEditingController();
  final _amount = TextEditingController();
  final _minTotal = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _type = 'percent';
  bool _active = true;
  DateTime? _expiresAt;

  @override
  void dispose() {
    _code.dispose();
    _amount.dispose();
    _minTotal.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AdminCouponsCubit>().createCoupon(
          code: _code.text.trim(),
          discountType: _type,
          amount: double.tryParse(_amount.text.trim()) ?? 0,
          minTotal: _minTotal.text.trim().isEmpty
              ? null
              : double.tryParse(_minTotal.text.trim()),
          expiresAt: _expiresAt,
          isActive: _active,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('add_coupon'.tr(), style: AppStyles.bold20),
            SizedBox(height: 16.h),
            CustomTextField(
                controller: _code,
                hint: 'coupon_code'.tr(),
                textCapitalization: TextCapitalization.characters),
            SizedBox(height: 14.h),
            Text('discount_type'.tr(), style: AppStyles.semiBold14),
            SizedBox(height: 8.h),
            Row(
              children: [
                _typeChip('percent', 'percent'.tr()),
                SizedBox(width: 10.w),
                _typeChip('fixed', 'fixed'.tr()),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                      controller: _amount,
                      hint: _type == 'percent'
                          ? 'percent_amount'.tr()
                          : 'amount'.tr(),
                      keyboardType: TextInputType.number),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomTextField(
                      controller: _minTotal,
                      hint: 'min_order'.tr(),
                      keyboardType: TextInputType.number,
                      validator: (_) => null),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _DateField(
                date: _expiresAt,
                onTap: _pickDate,
                onClear: () => setState(() => _expiresAt = null)),
            SwitchListTile(
              value: _active,
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Text('active'.tr(), style: AppStyles.medium14),
              onChanged: (v) => setState(() => _active = v),
            ),
            SizedBox(height: 8.h),
            BlocConsumer<AdminCouponsCubit, AdminCouponsState>(
              listener: (context, state) {
                if (state is AdminCouponSaved) Navigator.pop(context);
              },
              builder: (context, state) => CustomButton(
                text: 'save'.tr(),
                isLoading: state is AdminCouponSaving,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label) {
    final cs = Theme.of(context).colorScheme;
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: AppColors.brandGradient)
                : null,
            color: selected ? null : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                color: selected ? Colors.transparent : cs.outline),
          ),
          child: Text(label,
              style: AppStyles.semiBold14.copyWith(
                  color: selected ? Colors.white : cs.onSurface)),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField(
      {required this.date, required this.onTap, required this.onClear});
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.event_outlined, size: 20.r, color: cs.onSurfaceVariant),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                date == null
                    ? 'expiry_optional'.tr()
                    : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
                style: AppStyles.regular14.copyWith(
                    color: date == null
                        ? cs.onSurfaceVariant
                        : cs.onSurface),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 18.r, color: cs.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}
