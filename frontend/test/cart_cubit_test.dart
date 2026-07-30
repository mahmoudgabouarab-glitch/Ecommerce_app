import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failure.dart';
import 'package:ecommerce_app/features/cart/data/models/cart_model.dart';
import 'package:ecommerce_app/features/cart/data/repo/cart_repo.dart';
import 'package:ecommerce_app/features/cart/presentation/view_model/cart_cubit/cart_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCartRepo implements CartRepo {
  Either<Failure, CartResponse> getCartResult =
      right(const CartResponse(items: [], subtotal: 0, count: 0));
  Either<Failure, Unit> mutateResult = right(unit);
  int getCartCalls = 0;

  @override
  Future<Either<Failure, CartResponse>> getCart() async {
    getCartCalls++;
    return getCartResult;
  }

  @override
  Future<Either<Failure, Unit>> addToCart({
    required int productId,
    int quantity = 1,
    int? variantId,
  }) async =>
      mutateResult;

  @override
  Future<Either<Failure, Unit>> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async =>
      mutateResult;

  @override
  Future<Either<Failure, Unit>> removeItem(int cartItemId) async => mutateResult;
}

void main() {
  late _FakeCartRepo repo;

  setUp(() => repo = _FakeCartRepo());

  test('getCart success emits CartSuccess', () async {
    final cubit = CartCubit(repo);

    await cubit.getCart();

    expect(cubit.state, isA<CartSuccess>());
    await cubit.close();
  });

  test('getCart failure emits CartFailure', () async {
    repo.getCartResult = left(ServiseFailure('boom'));
    final cubit = CartCubit(repo);

    await cubit.getCart();

    expect(cubit.state, isA<CartFailure>());
    await cubit.close();
  });

  test('updateQuantity below 1 is a no-op', () async {
    final cubit = CartCubit(repo);

    await cubit.updateQuantity(1, 0);

    expect(cubit.state, isA<CartInitial>());
    expect(repo.getCartCalls, 0);
    await cubit.close();
  });

  test('successful updateQuantity reloads the cart', () async {
    final cubit = CartCubit(repo);
    await cubit.getCart();

    await cubit.updateQuantity(1, 3);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(cubit.state, isA<CartSuccess>());
    expect(repo.getCartCalls, 2);
    await cubit.close();
  });

  test('failed mutation on a loaded cart emits CartActionError', () async {
    final cubit = CartCubit(repo);
    await cubit.getCart();
    repo.mutateResult = left(ServiseFailure('nope'));

    await cubit.updateQuantity(1, 3);

    expect(cubit.state, isA<CartActionError>());
    await cubit.close();
  });

  test('failed mutation with no loaded cart emits CartFailure', () async {
    repo.mutateResult = left(ServiseFailure('nope'));
    final cubit = CartCubit(repo);

    await cubit.removeItem(1);

    expect(cubit.state, isA<CartFailure>());
    await cubit.close();
  });
}
