import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/order_model.dart';

abstract class OrderRepo {
  Future<Either<Failure, int>> createAddress({
    required String fullName,
    required String phone,
    required String line1,
    required String city,
  });

  Future<Either<Failure, OrderModel>> placeOrder({
    required int addressId,
    required String paymentMethod,
    String? couponCode,
  });

  Future<Either<Failure, OrdersResponse>> getOrders();

  Future<Either<Failure, OrderModel>> getOrder(int orderId);

  Future<Either<Failure, String>> payCard(int orderId);

  Future<Either<Failure, double>> applyCoupon(String code);

  Future<Either<Failure, Unit>> cancelOrder(int orderId);
}
