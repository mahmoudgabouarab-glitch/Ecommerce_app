part of 'details_cubit.dart';

sealed class DetailsState extends Equatable {
  const DetailsState();

  @override
  List<Object> get props => [];
}

final class DetailsInitial extends DetailsState {}

final class DetailsLoading extends DetailsState {}

final class DetailsSuccess extends DetailsState {
  final ProductModel product;
  const DetailsSuccess(this.product);

  @override
  List<Object> get props => [product];
}

final class DetailsFailure extends DetailsState {
  final String error;
  const DetailsFailure(this.error);

  @override
  List<Object> get props => [error];
}
