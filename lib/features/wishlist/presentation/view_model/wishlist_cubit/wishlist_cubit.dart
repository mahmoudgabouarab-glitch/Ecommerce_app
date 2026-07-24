import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../home/data/models/product_model.dart';
import '../../../data/repo/wishlist_repo.dart';

part 'wishlist_state.dart';

/// Shared cubit holding the set of favorite product ids (for hearts) and the
/// full favorite product list (for the wishlist screen).
class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit(this._repo) : super(WishlistInitial());

  final WishlistRepo _repo;

  final Set<int> _ids = {};
  List<ProductModel> _products = [];

  bool isFavorite(int id) => _ids.contains(id);

  Future<void> getWishlist() async {
    emit(WishlistLoading());
    final result = await _repo.getWishlist();
    result.fold(
      (failure) => emit(WishlistError(failure.errorMessage)),
      (products) {
        _products = products;
        _ids
          ..clear()
          ..addAll(products.map((p) => p.id));
        _emitLoaded();
      },
    );
  }

  Future<void> toggle(int productId) async {
    final wasFav = _ids.contains(productId);
    // Optimistic update so the heart reacts instantly.
    wasFav ? _ids.remove(productId) : _ids.add(productId);
    _emitLoaded();

    final result = await _repo.toggle(productId);
    result.fold(
      (_) {
        // Revert on failure.
        wasFav ? _ids.add(productId) : _ids.remove(productId);
        _emitLoaded();
      },
      (_) => getWishlist(), // refresh the full list
    );
  }

  void _emitLoaded() =>
      emit(WishlistLoaded(List.of(_products), Set.of(_ids)));
}
