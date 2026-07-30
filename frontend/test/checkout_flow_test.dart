import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failure.dart';
import 'package:ecommerce_app/features/address/data/models/address_model.dart';
import 'package:ecommerce_app/features/address/data/repo/address_repo.dart';
import 'package:ecommerce_app/features/checkout/presentation/view_model/checkout_cubit/checkout_cubit.dart';
import 'package:ecommerce_app/features/order/data/models/order_model.dart';
import 'package:ecommerce_app/features/order/data/repo/order_repo.dart';
import 'package:flutter_test/flutter_test.dart';

OrderModel _order({
  String paymentMethod = 'cash',
  String paymentStatus = 'unpaid',
}) =>
    OrderModel(
      id: 1,
      status: 'pending',
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      subtotal: 200,
      discount: 0,
      shippingFee: 50,
      total: 250,
      couponCode: null,
      items: const [],
      createdAt: null,
    );

class _FakeAddressRepo implements AddressRepo {
  @override
  Future<Either<Failure, List<AddressModel>>> getAddresses() async => right([]);
  @override
  Future<Either<Failure, AddressModel>> save({
    int? id,
    required String fullName,
    required String phone,
    required String line1,
    required String city,
    bool isDefault = false,
  }) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, Unit>> delete(int id) => throw UnimplementedError();
}

class _FakeOrderRepo implements OrderRepo {
  Either<Failure, double> couponResult = right(20);
  Either<Failure, OrderModel> placeResult = right(_order());
  Either<Failure, String> payResult = right('https://paymob/iframe?token=abc');
  Either<Failure, OrderModel> getOrderResult =
      right(_order(paymentStatus: 'paid'));

  @override
  Future<Either<Failure, double>> applyCoupon(String code) async =>
      couponResult;

  @override
  Future<Either<Failure, OrderModel>> placeOrder({
    required int addressId,
    required String paymentMethod,
    String? couponCode,
  }) async =>
      placeResult;

  @override
  Future<Either<Failure, int>> createAddress({
    required String fullName,
    required String phone,
    required String line1,
    required String city,
  }) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, OrdersResponse>> getOrders() =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, OrderModel>> getOrder(int orderId) async =>
      getOrderResult;
  @override
  Future<Either<Failure, String>> payCard(int orderId) async => payResult;
  @override
  Future<Either<Failure, Unit>> cancelOrder(int orderId) =>
      throw UnimplementedError();
}

void main() {
  late _FakeOrderRepo orderRepo;

  setUp(() => orderRepo = _FakeOrderRepo());

  CheckoutCubit build() => CheckoutCubit(orderRepo, _FakeAddressRepo());

  test('applying a valid coupon stores the discount', () async {
    orderRepo.couponResult = right(20);
    final cubit = build();
    cubit.couponController.text = 'SAVE10';

    await cubit.applyCoupon();

    expect(cubit.state, isA<CouponApplied>());
    expect(cubit.discount, 20);
    expect(cubit.appliedCoupon, 'SAVE10');
    await cubit.close();
  });

  test('an invalid coupon emits CouponInvalid and clears the discount', () async {
    orderRepo.couponResult = left(ServiseFailure('bad code'));
    final cubit = build();
    cubit.couponController.text = 'NOPE';

    await cubit.applyCoupon();

    expect(cubit.state, isA<CouponInvalid>());
    expect(cubit.discount, 0);
    expect(cubit.appliedCoupon, isNull);
    await cubit.close();
  });

  test('placing an order with a selected address succeeds', () async {
    orderRepo.placeResult = right(_order());
    final cubit = build();
    cubit.selectAddress(3);

    await cubit.placeOrder();

    expect(cubit.state, isA<CheckoutSuccess>());
    await cubit.close();
  });

  test('a failed order emits CheckoutFailure', () async {
    orderRepo.placeResult = left(ServiseFailure('server error'));
    final cubit = build();
    cubit.selectAddress(3);

    await cubit.placeOrder();

    expect(cubit.state, isA<CheckoutFailure>());
    await cubit.close();
  });

  test('a card order starts payment and emits CheckoutCardPayment', () async {
    orderRepo.placeResult = right(_order(paymentMethod: 'card'));
    orderRepo.payResult = right('https://paymob/iframe?token=xyz');
    final cubit = build();
    cubit.setPaymentMethod('card');
    cubit.selectAddress(3);

    await cubit.placeOrder();

    expect(cubit.state, isA<CheckoutCardPayment>());
    expect((cubit.state as CheckoutCardPayment).iframeUrl,
        'https://paymob/iframe?token=xyz');
    await cubit.close();
  });

  test('a failed payment start emits CheckoutFailure', () async {
    orderRepo.placeResult = right(_order(paymentMethod: 'card'));
    orderRepo.payResult = left(ServiseFailure('gateway down'));
    final cubit = build();
    cubit.setPaymentMethod('card');
    cubit.selectAddress(3);

    await cubit.placeOrder();

    expect(cubit.state, isA<CheckoutFailure>());
    await cubit.close();
  });

  test('confirmCardPayment returns true when the order is paid', () async {
    orderRepo.getOrderResult = right(_order(paymentStatus: 'paid'));
    final cubit = build();

    expect(await cubit.confirmCardPayment(1), isTrue);
    await cubit.close();
  });

  test('confirmCardPayment returns false when it stays unpaid', () async {
    orderRepo.getOrderResult = right(_order(paymentStatus: 'unpaid'));
    final cubit = build();

    expect(
      await cubit.confirmCardPayment(1, retries: 2, delay: Duration.zero),
      isFalse,
    );
    await cubit.close();
  });
}
