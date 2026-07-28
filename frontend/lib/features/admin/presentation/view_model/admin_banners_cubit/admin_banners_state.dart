part of 'admin_banners_cubit.dart';

sealed class AdminBannersState extends Equatable {
  const AdminBannersState();

  @override
  List<Object> get props => [];
}

final class AdminBannersInitial extends AdminBannersState {}

final class AdminBannersLoading extends AdminBannersState {}

final class AdminBannersLoaded extends AdminBannersState {
  final List<BannerModel> banners;
  const AdminBannersLoaded(this.banners);

  @override
  List<Object> get props => [banners];
}

final class AdminBannerSaving extends AdminBannersState {}

final class AdminBannerSaved extends AdminBannersState {}

final class AdminBannersFailure extends AdminBannersState {
  final String error;
  const AdminBannersFailure(this.error);

  @override
  List<Object> get props => [error];
}
