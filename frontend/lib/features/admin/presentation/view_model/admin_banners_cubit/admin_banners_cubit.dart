import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../home/data/models/banner_model.dart';
import '../../../data/repo/admin_repo.dart';

part 'admin_banners_state.dart';

class AdminBannersCubit extends Cubit<AdminBannersState> {
  AdminBannersCubit(this._repo) : super(AdminBannersInitial());

  final AdminRepo _repo;

  Future<void> getBanners() async {
    emit(AdminBannersLoading());
    final result = await _repo.getBanners();
    result.fold(
      (failure) => emit(AdminBannersFailure(failure.errorMessage)),
      (banners) => emit(AdminBannersLoaded(banners)),
    );
  }

  Future<void> saveBanner({
    int? id,
    String? title,
    String? subtitle,
    required String linkType,
    int? linkValue,
    required bool isActive,
    int sortOrder = 0,
    String? imagePath,
  }) async {
    emit(AdminBannerSaving());
    final result = await _repo.saveBanner(
      id: id,
      title: title,
      subtitle: subtitle,
      linkType: linkType,
      linkValue: linkValue,
      isActive: isActive,
      sortOrder: sortOrder,
      imagePath: imagePath,
    );
    result.fold(
      (failure) => emit(AdminBannersFailure(failure.errorMessage)),
      (_) {
        emit(AdminBannerSaved());
        getBanners();
      },
    );
  }

  Future<void> deleteBanner(int id) async {
    final result = await _repo.deleteBanner(id);
    result.fold(
      (failure) => emit(AdminBannersFailure(failure.errorMessage)),
      (_) => getBanners(),
    );
  }
}
