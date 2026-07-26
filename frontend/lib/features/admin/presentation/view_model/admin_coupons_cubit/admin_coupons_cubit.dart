import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/coupon_model.dart';
import '../../../data/repo/admin_repo.dart';

part 'admin_coupons_state.dart';

class AdminCouponsCubit extends Cubit<AdminCouponsState> {
  AdminCouponsCubit(this._repo) : super(AdminCouponsInitial());

  final AdminRepo _repo;

  Future<void> getCoupons() async {
    emit(AdminCouponsLoading());
    final result = await _repo.getCoupons();
    result.fold(
      (failure) => emit(AdminCouponsFailure(failure.errorMessage)),
      (coupons) => emit(AdminCouponsLoaded(coupons)),
    );
  }

  Future<void> createCoupon({
    required String code,
    required String discountType,
    required double amount,
    double? minTotal,
    DateTime? expiresAt,
    bool isActive = true,
  }) async {
    emit(AdminCouponSaving());
    final result = await _repo.createCoupon(
      code: code,
      discountType: discountType,
      amount: amount,
      minTotal: minTotal,
      expiresAt: expiresAt,
      isActive: isActive,
    );
    result.fold(
      (failure) => emit(AdminCouponsFailure(failure.errorMessage)),
      (_) {
        emit(AdminCouponSaved());
        getCoupons();
      },
    );
  }

  Future<void> deleteCoupon(int id) async {
    final result = await _repo.deleteCoupon(id);
    result.fold(
      (failure) => emit(AdminCouponsFailure(failure.errorMessage)),
      (_) => getCoupons(),
    );
  }
}
