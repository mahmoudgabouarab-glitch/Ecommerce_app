import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/order_model.dart';

abstract class OrderRepo {
  /// Create a shipping address and return its id.
  Future<Either<Failure, int>> createAddress({
    required String fullName,
    required String phone,
    required String line1,
    required String city,
  });

  /// Place an order from the current cart.
  Future<Either<Failure, OrderModel>> placeOrder({
    required int addressId,
    required String paymentMethod, // 'cash' | 'card'
    String? couponCode,
  });

  Future<Either<Failure, OrdersResponse>> getOrders();

  /// Validate a coupon against the current cart; returns the discount amount.
  Future<Either<Failure, double>> applyCoupon(String code);

  /// Cancel a pending order.
  Future<Either<Failure, Unit>> cancelOrder(int orderId);
}
