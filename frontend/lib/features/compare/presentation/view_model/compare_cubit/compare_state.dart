part of 'compare_cubit.dart';

sealed class CompareState extends Equatable {
  const CompareState();

  @override
  List<Object> get props => [];
}

final class CompareUpdated extends CompareState {
  final List<ProductModel> items;
  const CompareUpdated(this.items);

  @override
  List<Object> get props => [items];
}
