import 'package:easy_localization/easy_localization.dart';
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
import 'compare/presentation/view/compare_view.dart';
import 'compare/presentation/view_model/compare_cubit/compare_cubit.dart';
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
  late final Animation<double> _pageCurve = CurvedAnimation(
    parent: _pageAnim,
    curve: Curves.easeOutCubic,
  );

  late final CartCubit _cartCubit = CartCubit(getIt<CartRepoImpl>())..getCart();
  late final OrdersCubit _ordersCubit = OrdersCubit(getIt<OrderRepoImpl>())
    ..getOrders();

  final _pages = const [
    HomeView(),
    CartView(),
    OrdersView(),
    CompareView(),
    SettingsView(),
  ];

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
    if (i == 4) context.read<NotificationsCubit>().refreshBadge();
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
      child: BlocListener<CompareCubit, CompareState>(
        listener: (context, state) {
          final count = state is CompareUpdated ? state.items.length : 0;
          if (count == 0 && _index == 3) setState(() => _index = 0);
        },
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
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final compareCount = context.watch<CompareCubit>().count;
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
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(
                      0,
                      Icons.home_outlined,
                      Icons.home_rounded,
                      'home'.tr(),
                    ),
                    _navItem(
                      1,
                      Icons.shopping_cart_outlined,
                      Icons.shopping_cart_rounded,
                      'cart'.tr(),
                      badge: count,
                    ),
                    _navItem(
                      2,
                      Icons.receipt_long_outlined,
                      Icons.receipt_long_rounded,
                      'orders'.tr(),
                    ),
                    if (compareCount > 0)
                      _navItem(
                        3,
                        Icons.compare_arrows_rounded,
                        Icons.compare_arrows_rounded,
                        'compare'.tr(),
                        badge: compareCount,
                      ),
                    _navItem(
                      4,
                      Icons.person_outline,
                      Icons.person_rounded,
                      'profile'.tr(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    int badge = 0,
  }) {
    final cs = Theme.of(context).colorScheme;
    final selected = _index == index;
    const duration = Duration(milliseconds: 260);

    Widget iconWidget = Icon(
      selected ? activeIcon : icon,
      color: selected ? AppColors.primary : cs.onSurfaceVariant,
      size: 23.r,
    );
    if (badge > 0) {
      iconWidget = Badge(label: Text('$badge'), child: iconWidget);
    }
    if (index == 1) {
      iconWidget = _BounceOnIncrease(value: badge, child: iconWidget);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onSelect(index),
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            AnimatedSize(
              duration: duration,
              curve: Curves.easeOut,
              child: selected
                  ? Padding(
                      padding: EdgeInsets.only(left: 7.w),
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BounceOnIncrease extends StatefulWidget {
  const _BounceOnIncrease({required this.value, required this.child});
  final int value;
  final Widget child;

  @override
  State<_BounceOnIncrease> createState() => _BounceOnIncreaseState();
}

class _BounceOnIncreaseState extends State<_BounceOnIncrease>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 45),
    TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 55),
  ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void didUpdateWidget(_BounceOnIncrease old) {
    super.didUpdateWidget(old);
    if (widget.value > old.value) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
