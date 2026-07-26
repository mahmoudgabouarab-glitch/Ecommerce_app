part of 'admin_products_cubit.dart';

sealed class AdminProductsState extends Equatable {
  const AdminProductsState();

  @override
  List<Object> get props => [];
}

final class AdminProductsInitial extends AdminProductsState {}

final class AdminProductsLoading extends AdminProductsState {}

final class AdminProductSaving extends AdminProductsState {}

final class AdminProductSaved extends AdminProductsState {}

final class AdminProductsLoaded extends AdminProductsState {
  final List<ProductModel> products;
  const AdminProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

final class AdminProductsFailure extends AdminProductsState {
  final String error;
  const AdminProductsFailure(this.error);

  @override
  List<Object> get props => [error];
}
