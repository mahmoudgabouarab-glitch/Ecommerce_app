import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/cache_helper.dart';
import '../network/cache_keys.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_load());

  static ThemeMode _load() {
    final saved = CacheHelper.getDataString(key: CacheKeys.themeMode);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setMode(ThemeMode mode) {
    CacheHelper.saveData(key: CacheKeys.themeMode, value: mode.name);
    emit(mode);
  }

  void toggle(BuildContext context) {
    final isDark =
        state == ThemeMode.dark ||
        (state == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
