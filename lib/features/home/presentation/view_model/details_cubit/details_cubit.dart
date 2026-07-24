import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repo/home_repo.dart';

part 'details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit(this._repo) : super(DetailsInitial());

  final HomeRepo _repo;

  Future<void> getDetails(int id) async {
    emit(DetailsLoading());
    final result = await _repo.getProductDetails(id);
    result.fold(
      (failure) => emit(DetailsFailure(failure.errorMessage)),
      (product) => emit(DetailsSuccess(product)),
    );
  }
}
