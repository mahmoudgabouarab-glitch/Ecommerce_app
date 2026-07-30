import 'package:ecommerce_app/core/network/cache_helper.dart';
import 'package:ecommerce_app/core/network/cache_keys.dart';
import 'package:ecommerce_app/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper().init();
  });

  test('defaults to system theme when nothing is stored', () {
    final cubit = ThemeCubit();

    expect(cubit.state, ThemeMode.system);
    return cubit.close();
  });

  test('setMode emits and persists the chosen theme', () async {
    final cubit = ThemeCubit();

    cubit.setMode(ThemeMode.dark);

    expect(cubit.state, ThemeMode.dark);
    expect(CacheHelper.getDataString(key: CacheKeys.themeMode), 'dark');
    await cubit.close();
  });

  test('restores the persisted theme on construction', () async {
    SharedPreferences.setMockInitialValues({CacheKeys.themeMode: 'dark'});
    await CacheHelper().init();

    final cubit = ThemeCubit();

    expect(cubit.state, ThemeMode.dark);
    await cubit.close();
  });
}
