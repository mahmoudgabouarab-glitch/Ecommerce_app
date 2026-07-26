import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_service.dart';
import '../models/order_model.dart';
import 'order_repo.dart';

class OrderRepoImpl implements OrderRepo {
  final ApiServise _api;

  OrderRepoImpl(this._api);

  @override
  Future<Either<Failure, int>> createAddress({
    required String fullName,
    required String phone,
    required String line1,
    required String city,
  }) async {
    try {
      final data = await _api.post(
        endpoint: "addresses",
        data: {
          "full_name": fullName,
          "phone": phone,
          "line1": line1,
          "city": city,
        },
      );
      final map = data['data'] as Map<String, dynamic>? ?? data;
      return Right(map['id'] as int);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, OrderModel>> placeOrder({
    required int addressId,
    required String paymentMethod,
    String? couponCode,
  }) async {
    try {
      final data = await _api.post(
        endpoint: "orders",
        data: {
          "address_id": addressId,
          "payment_method": paymentMethod,
          if (couponCode != null && couponCode.isNotEmpty)
            "coupon_code": couponCode,
        },
      );
      final map = data['data'] as Map<String, dynamic>? ?? data;
      return Right(OrderModel.fromJson(map));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, OrdersResponse>> getOrders() async {
    try {
      final data = await _api.get(endpoint: "orders");
      return Right(OrdersResponse.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, double>> applyCoupon(String code) async {
    try {
      final data = await _api.post(
        endpoint: "coupons/apply",
        data: {"code": code},
      );
      final discount = data['discount'];
      final value = discount is num
          ? discount.toDouble()
          : double.tryParse('$discount') ?? 0;
      return Right(value);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelOrder(int orderId) async {
    try {
      await _api.patch(endpoint: "orders/$orderId/cancel");
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
