import 'package:flutter/material.dart';

import '../network/cache_helper.dart';
import '../network/cache_keys.dart';

bool isLoggedInUser() {
  final token = CacheHelper.getDataString(key: CacheKeys.token);
  return token != null && token.isNotEmpty;
}

bool isGuestUser() => CacheHelper.getData(key: CacheKeys.isGuest) == true;

String formatPrice(num value) => '${value.toStringAsFixed(0)} EGP';

Route<T> _animatedRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

void pushAndRemoveUntil(BuildContext context, Widget page) {
  Navigator.of(context).pushAndRemoveUntil(_animatedRoute(page), (_) => false);
}

Future<T?> push<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(_animatedRoute<T>(page));
}

void pushAndKeepFirst(BuildContext context, Widget page) {
  Navigator.of(
    context,
  ).pushAndRemoveUntil(_animatedRoute(page), (route) => route.isFirst);
}
