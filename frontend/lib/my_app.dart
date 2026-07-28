import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/network/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/notifications/data/repo/notifications_repo_impl.dart';
import 'features/notifications/presentation/view_model/notifications_cubit/notifications_cubit.dart';
import 'features/splash/splash_view.dart';
import 'features/wishlist/data/repo/wishlist_repo_impl.dart';
import 'features/wishlist/presentation/view_model/wishlist_cubit/wishlist_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => WishlistCubit(getIt<WishlistRepoImpl>())),
        BlocProvider(
            create: (_) =>
                NotificationsCubit(getIt<NotificationsRepoImpl>())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, _) => BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => MaterialApp(
            title: 'Bazar',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const SplashView(),
          ),
        ),
      ),
    );
  }
}
