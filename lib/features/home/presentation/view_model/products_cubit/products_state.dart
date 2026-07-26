part of 'products_cubit.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

final class ProductsInitial extends ProductsState {}

final class ProductsLoading extends ProductsState {}

final class ProductsSuccess extends ProductsState {
  final List<ProductModel> products;
  final bool hasReachedMax;
  final bool loadingMore;

  const ProductsSuccess(
    this.products, {
    this.hasReachedMax = true,
    this.loadingMore = false,
  });

  @override
  List<Object> get props => [products, hasReachedMax, loadingMore];
}

final class ProductsFailure extends ProductsState {
  final String error;
  const ProductsFailure(this.error);

  @override
  List<Object> get props => [error];
}
