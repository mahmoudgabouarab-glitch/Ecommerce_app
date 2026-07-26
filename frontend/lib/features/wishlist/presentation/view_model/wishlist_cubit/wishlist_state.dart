part of 'wishlist_cubit.dart';

sealed class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object> get props => [];
}

final class WishlistInitial extends WishlistState {}

final class WishlistLoading extends WishlistState {}

final class WishlistLoaded extends WishlistState {
  final List<ProductModel> products;
  final Set<int> ids;
  const WishlistLoaded(this.products, this.ids);

  @override
  List<Object> get props => [products, ids];
}

final class WishlistError extends WishlistState {
  final String error;
  const WishlistError(this.error);

  @override
  List<Object> get props => [error];
}
