part of 'search_cubit.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchIdle extends SearchState {
  final List<String> recent;
  const SearchIdle(this.recent);

  @override
  List<Object?> get props => [recent];
}

final class SearchLoading extends SearchState {}

final class SearchResults extends SearchState {
  final List<ProductModel> products;
  const SearchResults(this.products);

  @override
  List<Object?> get props => [products];
}

final class SearchFailure extends SearchState {
  final String error;
  const SearchFailure(this.error);

  @override
  List<Object?> get props => [error];
}
