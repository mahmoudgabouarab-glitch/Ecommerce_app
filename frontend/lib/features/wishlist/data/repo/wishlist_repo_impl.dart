import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../../../home/data/models/product_model.dart';
import 'wishlist_repo.dart';

class WishlistRepoImpl implements WishlistRepo {
  final ApiServise _api;

  WishlistRepoImpl(this._api);

  @override
  Future<Either<Failure, List<ProductModel>>> getWishlist() async {
    try {
      final data = await _api.get(endpoint: ApiEndpoints.wishlist);
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> toggle(int productId) async {
    try {
      final data = await _api.post(endpoint: ApiEndpoints.wishlistItem(productId));
      return Right(data['in_wishlist'] as bool? ?? false);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  Failure _handle(Object e) {
    if (e is DioException) return ServiseFailure.fromDioException(e);
    return ServiseFailure(e.toString());
  }
}
