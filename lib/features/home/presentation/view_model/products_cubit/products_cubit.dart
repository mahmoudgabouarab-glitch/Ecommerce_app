import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repo/home_repo.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._repo) : super(ProductsInitial());

  final HomeRepo _repo;

  int? _categoryId;
  String? _search;
  String? _sort;
  double? _minPrice;
  double? _maxPrice;

  static const int _perPage = 6;
  final List<ProductModel> _products = [];
  int _page = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  String? get sort => _sort;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  Future<void> getProducts({
    int? categoryId,
    String? search,
    String? sort,
    bool resetFilters = false,
  }) async {
    if (resetFilters) {
      _categoryId = null;
      _search = null;
      _sort = null;
      _minPrice = null;
      _maxPrice = null;
    }
    _categoryId = categoryId ?? _categoryId;
    _search = search ?? _search;
    _sort = sort ?? _sort;

    await _fetchFirstPage();
  }

  Future<void> applyFilters({
    String? sort,
    double? minPrice,
    double? maxPrice,
  }) async {
    _sort = sort;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    await _fetchFirstPage();
  }

  Future<void> filterByCategory(int? categoryId) =>
      getProducts(categoryId: categoryId, resetFilters: true);

  Future<void> _fetchFirstPage() async {
    emit(ProductsLoading());
    _page = 1;
    final result = await _repo.getProducts(
      categoryId: _categoryId,
      search: _search,
      sort: _sort,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      page: 1,
      perPage: _perPage,
    );
    result.fold((failure) => emit(ProductsFailure(failure.errorMessage)), (
      response,
    ) {
      _products
        ..clear()
        ..addAll(response.data);
      _lastPage = response.lastPage;
      emit(
        ProductsSuccess(List.of(_products), hasReachedMax: _page >= _lastPage),
      );
    });
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _page >= _lastPage) return;

    _isLoadingMore = true;
    emit(
      ProductsSuccess(
        List.of(_products),
        hasReachedMax: false,
        loadingMore: true,
      ),
    );

    final result = await _repo.getProducts(
      categoryId: _categoryId,
      search: _search,
      sort: _sort,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      page: _page + 1,
      perPage: _perPage,
    );
    result.fold(
      (_) {
        emit(
          ProductsSuccess(
            List.of(_products),
            hasReachedMax: _page >= _lastPage,
          ),
        );
      },
      (response) {
        _page += 1;
        _lastPage = response.lastPage;
        _products.addAll(response.data);
        emit(
          ProductsSuccess(
            List.of(_products),
            hasReachedMax: _page >= _lastPage,
          ),
        );
      },
    );
    _isLoadingMore = false;
  }
}
