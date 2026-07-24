import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/service_locator.dart';
import '../../../address/data/repo/address_repo_impl.dart';
import '../../../order/data/repo/order_repo_impl.dart';
import '../view_model/checkout_cubit/checkout_cubit.dart';
import 'widgets/checkout_body.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key, required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutCubit(
        getIt<OrderRepoImpl>(),
        getIt<AddressRepoImpl>(),
      )..loadAddresses(),
      child: Scaffold(
        appBar: AppBar(title: Text('checkout'.tr())),
        body: SafeArea(child: CheckoutBody(subtotal: subtotal)),
      ),
    );
  }
}
