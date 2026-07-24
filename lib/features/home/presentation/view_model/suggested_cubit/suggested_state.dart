part of 'suggested_cubit.dart';

sealed class SuggestedState extends Equatable {
  const SuggestedState();

  @override
  List<Object> get props => [];
}

final class SuggestedInitial extends SuggestedState {}

final class SuggestedLoading extends SuggestedState {}

final class SuggestedSuccess extends SuggestedState {
  final List<ProductModel> products;
  const SuggestedSuccess(this.products);

  @override
  List<Object> get props => [products];
}

final class SuggestedFailure extends SuggestedState {
  final String error;
  const SuggestedFailure(this.error);

  @override
  List<Object> get props => [error];
}
