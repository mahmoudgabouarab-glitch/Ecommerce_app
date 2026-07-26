import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/cart_model.dart';

abstract class CartRepo {
  Future<Either<Failure, CartResponse>> getCart();

  Future<Either<Failure, Unit>> addToCart({
    required int productId,
    int quantity = 1,
    int? variantId,
  });

  Future<Either<Failure, Unit>> updateQuantity({
    required int cartItemId,
    required int quantity,
  });

  Future<Either<Failure, Unit>> removeItem(int cartItemId);
}
