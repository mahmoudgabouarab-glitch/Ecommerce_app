import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cart_model.dart';
import '../../../data/repo/cart_repo.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repo) : super(CartInitial());

  final CartRepo _repo;

  // Last successfully loaded cart, kept so a failed action can keep it on screen.
  CartResponse? _cart;

  Future<void> getCart() async {
    emit(CartLoading());
    final result = await _repo.getCart();
    result.fold(
      (failure) => emit(CartFailure(failure.errorMessage)),
      (cart) {
        _cart = cart;
        emit(CartSuccess(cart));
      },
    );
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity < 1) return;
    final result =
        await _repo.updateQuantity(cartItemId: cartItemId, quantity: quantity);
    result.fold(
      (failure) => _emitActionError(failure.errorMessage),
      (_) => getCart(),
    );
  }

  Future<void> removeItem(int cartItemId) async {
    final result = await _repo.removeItem(cartItemId);
    result.fold(
      (failure) => _emitActionError(failure.errorMessage),
      (_) => getCart(),
    );
  }

  /// Surface an action failure as a transient error while keeping the cart
  /// visible (falls back to a full failure only if we have no cart yet).
  void _emitActionError(String message) {
    if (_cart != null) {
      emit(CartActionError(_cart!, message));
    } else {
      emit(CartFailure(message));
    }
  }
}
