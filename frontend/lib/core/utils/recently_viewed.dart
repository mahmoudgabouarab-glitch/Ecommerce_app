import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/home/data/models/product_model.dart';
import '../network/cache_helper.dart';
import '../network/cache_keys.dart';

class RecentlyViewed {
  RecentlyViewed._();

  static const int _max = 12;
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static void add(ProductModel product) {
    final list = CacheHelper.getStringList(key: CacheKeys.recentlyViewed);
    list.removeWhere((s) {
      try {
        return jsonDecode(s)['id'] == product.id;
      } catch (_) {
        return false;
      }
    });
    list.insert(0, jsonEncode(product.toJson()));
    if (list.length > _max) list.removeRange(_max, list.length);
    CacheHelper.saveData(key: CacheKeys.recentlyViewed, value: list);
    revision.value++;
  }

  static List<ProductModel> items() {
    return CacheHelper.getStringList(key: CacheKeys.recentlyViewed)
        .map((s) {
          try {
            return ProductModel.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<ProductModel>()
        .toList();
  }
}
