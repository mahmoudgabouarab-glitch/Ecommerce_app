part of 'admin_coupons_cubit.dart';

sealed class AdminCouponsState extends Equatable {
  const AdminCouponsState();

  @override
  List<Object> get props => [];
}

final class AdminCouponsInitial extends AdminCouponsState {}

final class AdminCouponsLoading extends AdminCouponsState {}

final class AdminCouponsLoaded extends AdminCouponsState {
  final List<CouponModel> coupons;
  const AdminCouponsLoaded(this.coupons);

  @override
  List<Object> get props => [coupons];
}

final class AdminCouponSaving extends AdminCouponsState {}

final class AdminCouponSaved extends AdminCouponsState {}

final class AdminCouponsFailure extends AdminCouponsState {
  final String error;
  const AdminCouponsFailure(this.error);

  @override
  List<Object> get props => [error];
}
