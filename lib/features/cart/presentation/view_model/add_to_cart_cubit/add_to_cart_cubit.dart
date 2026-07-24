import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/cart_repo.dart';

part 'add_to_cart_state.dart';

class AddToCartCubit extends Cubit<AddToCartState> {
  AddToCartCubit(this._repo) : super(AddToCartInitial());

  final CartRepo _repo;

  Future<void> addToCart({
    required int productId,
    int quantity = 1,
    int? variantId,
  }) async {
    emit(AddToCartLoading());
    final result = await _repo.addToCart(
      productId: productId,
      quantity: quantity,
      variantId: variantId,
    );
    result.fold(
      (failure) => emit(AddToCartFailure(failure.errorMessage)),
      (_) => emit(AddToCartSuccess()),
    );
  }
}
