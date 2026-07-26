import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/category_model.dart';
import '../../../data/repo/home_repo.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repo) : super(CategoriesInitial());

  final HomeRepo _repo;

  Future<void> getCategories() async {
    emit(CategoriesLoading());
    final result = await _repo.getCategories();
    result.fold(
      (failure) => emit(CategoriesFailure(failure.errorMessage)),
      (response) => emit(CategoriesSuccess(response.data)),
    );
  }
}
