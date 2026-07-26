part of 'checkout_cubit.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object> get props => [];
}

final class CheckoutInitial extends CheckoutState {}

final class CheckoutAddressesChanged extends CheckoutState {
  final int? selectedAddressId;
  final bool useNewAddress;
  const CheckoutAddressesChanged(this.selectedAddressId, this.useNewAddress);

  @override
  List<Object> get props => [selectedAddressId ?? -1, useNewAddress];
}

final class CheckoutLoading extends CheckoutState {}

final class CheckoutPaymentChanged extends CheckoutState {
  final String method;
  const CheckoutPaymentChanged(this.method);

  @override
  List<Object> get props => [method];
}

final class CouponLoading extends CheckoutState {}

final class CouponApplied extends CheckoutState {
  final double discount;
  const CouponApplied(this.discount);

  @override
  List<Object> get props => [discount];
}

final class CouponInvalid extends CheckoutState {
  final String message;
  const CouponInvalid(this.message);

  @override
  List<Object> get props => [message];
}

final class CheckoutSuccess extends CheckoutState {
  final OrderModel order;
  const CheckoutSuccess(this.order);

  @override
  List<Object> get props => [order];
}

final class CheckoutFailure extends CheckoutState {
  final String error;
  const CheckoutFailure(this.error);

  @override
  List<Object> get props => [error];
}
