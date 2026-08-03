import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/cart_model.dart';
import 'cart_repo.dart';

class CartRepoImpl implements CartRepo {
  final ApiServise _api;

  CartRepoImpl(this._api);

  @override
  Future<Either<Failure, CartResponse>> getCart() async {
    try {
      final data = await _api.get(endpoint: ApiEndpoints.cart);
      return Right(CartResponse.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> addToCart({
    required int productId,
    int quantity = 1,
    int? variantId,
  }) async {
    try {
      await _api.post(
        endpoint: ApiEndpoints.cart,
        data: {
          "product_id": productId,
          "quantity": quantity,
          "variant_id": ?variantId,
        },
      );
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      await _api.put(endpoint: ApiEndpoints.cartItem(cartItemId), data: {"quantity": quantity});
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeItem(int cartItemId) async {
    try {
      await _api.delete(endpoint: ApiEndpoints.cartItem(cartItemId));
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  Failure _handle(Object e) {
    if (e is DioException) return ServiseFailure.fromDioException(e);
    return ServiseFailure(e.toString());
  }
}
