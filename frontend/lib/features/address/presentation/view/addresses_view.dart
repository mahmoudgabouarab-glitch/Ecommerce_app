import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/service_locator.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/repo/address_repo_impl.dart';
import '../view_model/address_cubit/address_cubit.dart';
import 'widgets/addresses/address_form.dart';
import 'widgets/addresses/addresses_body.dart';

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
            onPressed: () => openAddressForm(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('add'.tr(), style: const TextStyle(color: Colors.white)),
          ),
          body: const SafeArea(child: AddressesBody()),
        );
      }),
    );
  }
}
