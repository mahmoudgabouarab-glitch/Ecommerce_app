import 'dart:convert';

import '../../../../core/network/cache_helper.dart';
import '../../../../core/network/cache_keys.dart';
import '../../../home/data/models/product_model.dart';
import 'compare_repo.dart';

class CompareRepoImpl implements CompareRepo {
  @override
  List<ProductModel> items() {
    return CacheHelper.getStringList(key: CacheKeys.compareList)
        .map((s) {
          try {
            return ProductModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<ProductModel>()
        .toList();
  }

  @override
  bool contains(int productId) => items().any((p) => p.id == productId);

  @override
  void add(ProductModel product) {
    if (contains(product.id)) return;
    final list = CacheHelper.getStringList(key: CacheKeys.compareList);
    list.add(jsonEncode(product.toJson()));
    CacheHelper.saveData(key: CacheKeys.compareList, value: list);
  }

  @override
  void remove(int productId) {
    final list = CacheHelper.getStringList(key: CacheKeys.compareList);
    list.removeWhere((s) {
      try {
        return jsonDecode(s)['id'] == productId;
      } catch (_) {
        return false;
      }
    });
    CacheHelper.saveData(key: CacheKeys.compareList, value: list);
  }

  @override
  void clear() {
    CacheHelper.saveData(key: CacheKeys.compareList, value: <String>[]);
  }
}
