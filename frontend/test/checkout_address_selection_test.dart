import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failure.dart';
import 'package:ecommerce_app/features/address/data/models/address_model.dart';
import 'package:ecommerce_app/features/address/data/repo/address_repo.dart';
import 'package:ecommerce_app/features/checkout/presentation/view_model/checkout_cubit/checkout_cubit.dart';
import 'package:ecommerce_app/features/order/data/models/order_model.dart';
import 'package:ecommerce_app/features/order/data/repo/order_repo.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal fakes — enough to exercise address selection without a backend.
class _FakeAddressRepo implements AddressRepo {
  @override
  Future<Either<Failure, List<AddressModel>>> getAddresses() async => right([]);
  @override
  Future<Either<Failure, AddressModel>> save(
          {int? id,
          required String fullName,
          required String phone,
          required String line1,
          required String city,
          bool isDefault = false}) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, Unit>> delete(int id) => throw UnimplementedError();
}

class _FakeOrderRepo implements OrderRepo {
  @override
  Future<Either<Failure, int>> createAddress(
          {required String fullName,
          required String phone,
          required String line1,
          required String city}) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, OrderModel>> placeOrder(
          {required int addressId,
          required String paymentMethod,
          String? couponCode}) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, OrdersResponse>> getOrders() =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, OrderModel>> getOrder(int orderId) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, String>> payCard(int orderId) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, double>> applyCoupon(String code) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, Unit>> cancelOrder(int orderId) =>
      throw UnimplementedError();
}

void main() {
  test('selecting a different address emits a distinct state (rebuild fires)',
      () async {
    final cubit = CheckoutCubit(_FakeOrderRepo(), _FakeAddressRepo());

    final emitted = <CheckoutState>[];
    final sub = cubit.stream.listen(emitted.add);

    // User taps address #1, then address #2, then back to #1.
    cubit.selectAddress(1);
    cubit.selectAddress(2);
    cubit.selectAddress(1);

    // Let the Cubit stream deliver the queued emissions.
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // Before the fix, states 2 and 3 were Equatable-equal to their predecessor
    // and Cubit dropped them, so the UI never rebuilt on the second tap.
    expect(emitted.length, 3,
        reason: 'each distinct address tap must emit a state');
    expect(cubit.selectedAddressId, 1);

    await sub.cancel();
    await cubit.close();
  });
}
