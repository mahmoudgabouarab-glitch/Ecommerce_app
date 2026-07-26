import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/models/address_model.dart';
import '../../data/repo/address_repo_impl.dart';
import '../view_model/address_cubit/address_cubit.dart';

class AddressesView extends StatelessWidget {
  const AddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressCubit(getIt<AddressRepoImpl>())..getAddresses(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text('my_addresses'.tr())),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('add'.tr(), style: const TextStyle(color: Colors.white)),
          ),
          body: SafeArea(
            child: BlocConsumer<AddressCubit, AddressState>(
              listener: (context, state) {
                if (state is AddressFailure) showSnackBar(context, state.error);
              },
              builder: (context, state) {
                if (state is AddressLoading || state is AddressInitial) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }
                final addresses =
                    state is AddressLoaded ? state.addresses : <AddressModel>[];
                if (addresses.isEmpty) {
                  return EmptyState(
                    icon: Icons.location_off_outlined,
                    title: 'no_addresses'.tr(),
                    subtitle: 'add_address_hint'.tr(),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, i) =>
                      _AddressCard(address: addresses[i]),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

void _openForm(BuildContext context, {AddressModel? existing}) {
  final cubit = context.read<AddressCubit>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _AddressForm(existing: existing),
    ),
  );
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});
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
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.fullName, style: AppStyles.semiBold14),
                    if (address.isDefault) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
                SizedBox(height: 4.h),
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
            onPressed: () => _openForm(context, existing: address),
            icon: Icon(Icons.edit_outlined, size: 20.r, color: cs.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () =>
                context.read<AddressCubit>().delete(address.id),
            icon: Icon(Icons.delete_outline, size: 20.r, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  const _AddressForm({this.existing});
  final AddressModel? existing;

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  late final _name = TextEditingController(text: widget.existing?.fullName);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _line1 = TextEditingController(text: widget.existing?.line1);
  late final _city = TextEditingController(text: widget.existing?.city);
  late bool _isDefault = widget.existing?.isDefault ?? false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line1.dispose();
    _city.dispose();
    super.dispose();
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
            Text(widget.existing == null ? 'add_address'.tr() : 'edit_address'.tr(),
                style: AppStyles.bold20),
            SizedBox(height: 16.h),
            CustomTextField(controller: _name, hint: 'full_name'.tr()),
            SizedBox(height: 12.h),
            CustomTextField(
                controller: _phone,
                hint: 'phone'.tr(),
                keyboardType: TextInputType.phone),
            SizedBox(height: 12.h),
            CustomTextField(controller: _line1, hint: 'address_line'.tr()),
            SizedBox(height: 12.h),
            CustomTextField(controller: _city, hint: 'city'.tr()),
            SizedBox(height: 8.h),
            SwitchListTile(
              value: _isDefault,
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Text('set_default'.tr(), style: AppStyles.medium14),
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            SizedBox(height: 8.h),
            BlocConsumer<AddressCubit, AddressState>(
              listener: (context, state) {
                if (state is AddressSaved) Navigator.pop(context);
              },
              builder: (context, state) => CustomButton(
                text: 'save'.tr(),
                isLoading: state is AddressSaving,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  context.read<AddressCubit>().save(
                        id: widget.existing?.id,
                        fullName: _name.text.trim(),
                        phone: _phone.text.trim(),
                        line1: _line1.text.trim(),
                        city: _city.text.trim(),
                        isDefault: _isDefault,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
