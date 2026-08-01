import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../../core/widgets/skeletons.dart';
import '../../../../../../core/widgets/state_views.dart';
import '../../../../data/models/address_model.dart';
import '../../../view_model/address_cubit/address_cubit.dart';
import 'address_card.dart';
import '../../../../../../core/utils/spacing.dart';

class AddressesBody extends StatelessWidget {
  const AddressesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state is AddressFailure) showSnackBar(context, state.error);
      },
      builder: (context, state) {
        if (state is AddressLoading || state is AddressInitial) {
          return const ListRowsShimmer(rowHeight: 92);
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
          separatorBuilder: (_, _) => spaceH(12),
          itemBuilder: (context, i) => AddressCard(address: addresses[i]),
        );
      },
    );
  }
}
