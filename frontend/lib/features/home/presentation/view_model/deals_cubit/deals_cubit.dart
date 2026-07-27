import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repo/home_repo.dart';

part 'deals_state.dart';

class DealsCubit extends Cubit<DealsState> {
  DealsCubit(this._repo) : super(DealsInitial());

  final HomeRepo _repo;

  Future<void> load() async {
    emit(DealsLoading());
    final result = await _repo.getDeals();
    result.fold(
      (failure) => emit(DealsFailure(failure.errorMessage)),
      (products) => emit(DealsSuccess(products)),
    );
  }
}
