import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/network/service_locator.dart';
import '../core/services/push_service.dart';
import '../core/utils/app_functions.dart';
import 'cart/data/repo/cart_repo_impl.dart';
import 'cart/presentation/view/cart_view.dart';
import 'cart/presentation/view_model/cart_cubit/cart_cubit.dart';
import 'home/presentation/view/home_view.dart';
import 'notifications/presentation/view_model/notifications_cubit/notifications_cubit.dart';
import 'order/data/repo/order_repo_impl.dart';
import 'order/presentation/view/orders_view.dart';
import 'order/presentation/view_model/orders_cubit/orders_cubit.dart';
import 'settings/presentation/view/settings_view.dart';
import 'wishlist/presentation/view_model/wishlist_cubit/wishlist_cubit.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, this.initialIndex = 0});

  /// Tab to open on first build (0 home, 1 cart, 2 orders, 3 profile).
  final int initialIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _index = widget.initialIndex;

  late final CartCubit _cartCubit = CartCubit(getIt<CartRepoImpl>())..getCart();
  late final OrdersCubit _ordersCubit = OrdersCubit(getIt<OrderRepoImpl>())
    ..getOrders();

  final _pages = const [HomeView(), CartView(), OrdersView(), SettingsView()];

  @override
  void initState() {
    super.initState();
    if (isLoggedInUser()) {
      context.read<WishlistCubit>().getWishlist();
      context.read<NotificationsCubit>().load();
      PushService.registerDevice();
    }
  }

  void _onSelect(int i) {
    setState(() => _index = i);
    if (!isLoggedInUser()) return;
    if (i == 1) _cartCubit.getCart();
    if (i == 2) _ordersCubit.getOrders();
    if (i == 3) context.read<NotificationsCubit>().refreshBadge();
  }

  @override
  void dispose() {
    _cartCubit.close();
    _ordersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cartCubit),
        BlocProvider.value(value: _ordersCubit),
      ],
      child: Scaffold(
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final count = state is CartSuccess ? state.cart.count : 0;
              return NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _onSelect,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: 'home'.tr(),
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.shopping_cart_rounded),
                    ),
                    label: 'cart'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.receipt_long_outlined),
                    selectedIcon: const Icon(Icons.receipt_long_rounded),
                    label: 'orders'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person_rounded),
                    label: 'profile'.tr(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
