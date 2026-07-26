import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repo/home_repo.dart';

part 'suggested_state.dart';

class SuggestedCubit extends Cubit<SuggestedState> {
  SuggestedCubit(this._repo) : super(SuggestedInitial());

  final HomeRepo _repo;

  Future<void> loadRelated(int productId) async {
    emit(SuggestedLoading());
    final result = await _repo.getRelated(productId);
    _emitResult(result);
  }

  Future<void> loadFeatured() async {
    emit(SuggestedLoading());
    final result = await _repo.getProducts(featured: true, perPage: 10);
    result.fold(
      (failure) => emit(SuggestedFailure(failure.errorMessage)),
      (response) => emit(SuggestedSuccess(response.data)),
    );
  }

  void _emitResult(dynamic result) {
    result.fold(
      (failure) => emit(SuggestedFailure(failure.errorMessage)),
      (list) => emit(SuggestedSuccess(list as List<ProductModel>)),
    );
  }
}
