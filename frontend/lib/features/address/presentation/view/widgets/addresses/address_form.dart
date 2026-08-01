import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../../data/models/address_model.dart';
import '../../../view_model/address_cubit/address_cubit.dart';
import '../../../../../../core/utils/spacing.dart';

void openAddressForm(BuildContext context, {AddressModel? existing}) {
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
      child: AddressForm(existing: existing),
    ),
  );
}

class AddressForm extends StatefulWidget {
  const AddressForm({super.key, this.existing});
  final AddressModel? existing;

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
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
            spaceH(16),
            CustomTextField(controller: _name, hint: 'full_name'.tr()),
            spaceH(12),
            CustomTextField(
                controller: _phone,
                hint: 'phone'.tr(),
                keyboardType: TextInputType.phone),
            spaceH(12),
            CustomTextField(controller: _line1, hint: 'address_line'.tr()),
            spaceH(12),
            CustomTextField(controller: _city, hint: 'city'.tr()),
            spaceH(8),
            SwitchListTile(
              value: _isDefault,
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Text('set_default'.tr(), style: AppStyles.medium14),
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            spaceH(8),
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
