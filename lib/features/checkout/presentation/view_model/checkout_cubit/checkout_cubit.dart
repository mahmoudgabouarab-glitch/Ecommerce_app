import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../address/data/models/address_model.dart';
import '../../../../address/data/repo/address_repo.dart';
import '../../../../order/data/models/order_model.dart';
import '../../../../order/data/repo/order_repo.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._repo, this._addressRepo) : super(CheckoutInitial());

  final OrderRepo _repo;
  final AddressRepo _addressRepo;

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final line1Controller = TextEditingController();
  final cityController = TextEditingController();
  final couponController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String paymentMethod = 'cash';
  double discount = 0;
  String? appliedCoupon;

  // Saved addresses. Default to the new-address form until saved ones load.
  List<AddressModel> addresses = [];
  int? selectedAddressId;
  bool useNewAddress = true;

  Future<void> loadAddresses() async {
    final result = await _addressRepo.getAddresses();
    result.fold((_) {}, (list) {
      addresses = list;
      if (list.isNotEmpty) {
        final def = list.firstWhere((a) => a.isDefault, orElse: () => list.first);
        selectedAddressId = def.id;
        useNewAddress = false;
      } else {
        useNewAddress = true;
      }
      emit(CheckoutAddressesChanged(selectedAddressId, useNewAddress));
    });
  }

  void selectAddress(int id) {
    selectedAddressId = id;
    useNewAddress = false;
    emit(CheckoutAddressesChanged(selectedAddressId, useNewAddress));
  }

  void useNew() {
    useNewAddress = true;
    selectedAddressId = null;
    emit(CheckoutAddressesChanged(selectedAddressId, useNewAddress));
  }

  void setPaymentMethod(String method) {
    paymentMethod = method;
    emit(CheckoutPaymentChanged(method));
  }

  Future<void> applyCoupon() async {
    final code = couponController.text.trim();
    if (code.isEmpty) return;

    emit(CouponLoading());
    final result = await _repo.applyCoupon(code);
    result.fold(
      (failure) {
        discount = 0;
        appliedCoupon = null;
        emit(CouponInvalid(failure.errorMessage));
      },
      (value) {
        discount = value;
        appliedCoupon = code;
        emit(CouponApplied(value));
      },
    );
  }

  Future<void> placeOrder() async {
    // Path 1: an existing saved address is selected.
    if (!useNewAddress && selectedAddressId != null) {
      emit(CheckoutLoading());
      await _submit(selectedAddressId!);
      return;
    }

    // Path 2: create a new address from the form first.
    if (!formKey.currentState!.validate()) return;
    emit(CheckoutLoading());

    final addressResult = await _repo.createAddress(
      fullName: fullNameController.text.trim(),
      phone: phoneController.text.trim(),
      line1: line1Controller.text.trim(),
      city: cityController.text.trim(),
    );
    await addressResult.fold(
      (failure) async => emit(CheckoutFailure(failure.errorMessage)),
      (addressId) async => _submit(addressId),
    );
  }

  Future<void> _submit(int addressId) async {
    final orderResult = await _repo.placeOrder(
      addressId: addressId,
      paymentMethod: paymentMethod,
      couponCode: appliedCoupon,
    );
    orderResult.fold(
      (failure) => emit(CheckoutFailure(failure.errorMessage)),
      (order) => emit(CheckoutSuccess(order)),
    );
  }

  @override
  Future<void> close() {
    fullNameController.dispose();
    phoneController.dispose();
    line1Controller.dispose();
    cityController.dispose();
    couponController.dispose();
    return super.close();
  }
}
