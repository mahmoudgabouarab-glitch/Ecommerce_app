import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'widgets/cart_body.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('my_cart'.tr())),
      body: const SafeArea(child: CartBody()),
    );
  }
}
