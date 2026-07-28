import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/banner_model.dart';
import '../../../data/repo/home_repo.dart';

part 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  BannersCubit(this._repo) : super(BannersInitial());

  final HomeRepo _repo;

  Future<void> load() async {
    emit(BannersLoading());
    final result = await _repo.getBanners();
    result.fold(
      (failure) => emit(BannersFailure(failure.errorMessage)),
      (banners) => emit(BannersSuccess(banners)),
    );
  }
}
