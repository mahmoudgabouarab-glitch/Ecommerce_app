import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/cache_helper.dart';
import '../../../../../core/network/cache_keys.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repo/home_repo.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repo) : super(SearchIdle(_loadRecent()));

  final HomeRepo _repo;

  static List<String> _loadRecent() =>
      CacheHelper.getStringList(key: CacheKeys.recentSearches);

  List<String> get recent => _loadRecent();

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      emit(SearchIdle(_loadRecent()));
      return;
    }
    emit(SearchLoading());
    final result = await _repo.getProducts(search: q, perPage: 20);
    result.fold(
      (f) => emit(SearchFailure(f.errorMessage)),
      (res) => emit(SearchResults(res.data)),
    );
  }

  Future<void> saveRecent(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final list = _loadRecent()..removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    list.insert(0, q);
    final capped = list.take(8).toList();
    await CacheHelper.saveData(key: CacheKeys.recentSearches, value: capped);
  }

  Future<void> clearRecent() async {
    await CacheHelper.saveData(
        key: CacheKeys.recentSearches, value: <String>[]);
    emit(SearchIdle(const []));
  }
}
