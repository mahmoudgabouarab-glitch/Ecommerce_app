part of 'deals_cubit.dart';

sealed class DealsState extends Equatable {
  const DealsState();

  @override
  List<Object> get props => [];
}

final class DealsInitial extends DealsState {}

final class DealsLoading extends DealsState {}

final class DealsSuccess extends DealsState {
  final List<ProductModel> products;
  const DealsSuccess(this.products);

  @override
  List<Object> get props => [products];
}

final class DealsFailure extends DealsState {
  final String error;
  const DealsFailure(this.error);

  @override
  List<Object> get props => [error];
}
