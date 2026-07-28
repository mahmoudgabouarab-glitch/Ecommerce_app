part of 'banners_cubit.dart';

sealed class BannersState extends Equatable {
  const BannersState();

  @override
  List<Object> get props => [];
}

final class BannersInitial extends BannersState {}

final class BannersLoading extends BannersState {}

final class BannersSuccess extends BannersState {
  final List<BannerModel> banners;
  const BannersSuccess(this.banners);

  @override
  List<Object> get props => [banners];
}

final class BannersFailure extends BannersState {
  final String error;
  const BannersFailure(this.error);

  @override
  List<Object> get props => [error];
}
