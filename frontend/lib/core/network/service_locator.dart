import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/address/data/repo/address_repo_impl.dart';
import '../../features/admin/data/repo/admin_repo_impl.dart';
import '../../features/auth/data/repo/auth_repo_impl.dart';
import '../../features/cart/data/repo/cart_repo_impl.dart';
import '../../features/compare/data/repo/compare_repo_impl.dart';
import '../../features/genie/data/repo/genie_repo_impl.dart';
import '../../features/home/data/repo/home_repo_impl.dart';
import '../../features/notifications/data/repo/notifications_repo_impl.dart';
import '../../features/order/data/repo/order_repo_impl.dart';
import '../../features/settings/data/repo/profile_repo_impl.dart';
import '../../features/wishlist/data/repo/wishlist_repo_impl.dart';
import 'api_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton<ApiServise>(ApiServise(Dio()));

  getIt.registerSingleton<AuthRepoImpl>(AuthRepoImpl(getIt<ApiServise>()));
  getIt.registerSingleton<AddressRepoImpl>(
    AddressRepoImpl(getIt<ApiServise>()),
  );
  getIt.registerSingleton<HomeRepoImpl>(HomeRepoImpl(getIt<ApiServise>()));
  getIt.registerSingleton<GenieRepoImpl>(GenieRepoImpl(getIt<ApiServise>()));
  getIt.registerSingleton<CartRepoImpl>(CartRepoImpl(getIt<ApiServise>()));
  getIt.registerSingleton<CompareRepoImpl>(CompareRepoImpl());
  getIt.registerSingleton<OrderRepoImpl>(OrderRepoImpl(getIt<ApiServise>()));
  getIt.registerSingleton<NotificationsRepoImpl>(
    NotificationsRepoImpl(getIt<ApiServise>()),
  );
  getIt.registerSingleton<WishlistRepoImpl>(
    WishlistRepoImpl(getIt<ApiServise>()),
  );
  getIt.registerSingleton<AdminRepoImpl>(AdminRepoImpl(getIt<ApiServise>()));
  getIt.registerSingleton<ProfileRepoImpl>(
    ProfileRepoImpl(getIt<ApiServise>()),
  );
}
