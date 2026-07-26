part of 'cart_cubit.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

final class CartInitial extends CartState {}

final class CartLoading extends CartState {}

final class CartSuccess extends CartState {
  final CartResponse cart;
  const CartSuccess(this.cart);

  @override
  List<Object> get props => [cart];
}

final class CartFailure extends CartState {
  final String error;
  const CartFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class CartActionError extends CartState {
  final CartResponse cart;
  final String error;
  const CartActionError(this.cart, this.error);

  @override
  List<Object> get props => [cart, error];
}
