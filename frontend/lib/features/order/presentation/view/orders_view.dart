import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'widgets/orders/orders_body.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('my_orders'.tr())),
      body: const SafeArea(child: OrdersBody()),
    );
  }
}
