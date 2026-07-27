import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/network/service_locator.dart';
import '../core/services/push_service.dart';
import '../core/utils/app_colors.dart';
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

  final int initialIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  late int _index = widget.initialIndex;

  late final AnimationController _pageAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..forward();
  late final Animation<double> _pageCurve =
      CurvedAnimation(parent: _pageAnim, curve: Curves.easeOutCubic);

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
    _pageAnim.forward(from: 0);
    if (!isLoggedInUser()) return;
    if (i == 1) _cartCubit.getCart();
    if (i == 2) _ordersCubit.getOrders();
    if (i == 3) context.read<NotificationsCubit>().refreshBadge();
  }

  @override
  void dispose() {
    _pageAnim.dispose();
    _cartCubit.close();
    _ordersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cartCubit),
        BlocProvider.value(value: _ordersCubit),
      ],
      child: Scaffold(
        body: FadeTransition(
          opacity: _pageCurve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(_pageCurve),
            child: IndexedStack(index: _index, children: _pages),
          ),
        ),
        bottomNavigationBar: _buildNavBar(context),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.h,
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final count = state is CartSuccess ? state.cart.count : 0;
              return Row(
                children: [
                  _navItem(0, Icons.home_outlined, Icons.home_rounded),
                  _navItem(1, Icons.shopping_cart_outlined,
                      Icons.shopping_cart_rounded,
                      badge: count),
                  _navItem(2, Icons.receipt_long_outlined,
                      Icons.receipt_long_rounded),
                  _navItem(3, Icons.person_outline, Icons.person_rounded),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon,
      {int badge = 0}) {
    final cs = Theme.of(context).colorScheme;
    final selected = _index == index;

    Widget iconWidget = Icon(
      selected ? activeIcon : icon,
      color: selected ? AppColors.primary : cs.onSurfaceVariant,
      size: 25.r,
    );
    if (badge > 0) {
      iconWidget = Badge(label: Text('$badge'), child: iconWidget);
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onSelect(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            SizedBox(height: 6.h),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: selected ? 1 : 0,
              child: Container(
                width: 6.r,
                height: 6.r,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.brandGradient),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
