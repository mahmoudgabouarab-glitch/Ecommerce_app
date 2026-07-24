part of 'admin_orders_cubit.dart';

sealed class AdminOrdersState extends Equatable {
  const AdminOrdersState();

  @override
  List<Object> get props => [];
}

final class AdminOrdersInitial extends AdminOrdersState {}

final class AdminOrdersLoading extends AdminOrdersState {}

final class AdminOrdersLoaded extends AdminOrdersState {
  final List<OrderModel> orders;
  const AdminOrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

final class AdminOrdersFailure extends AdminOrdersState {
  final String error;
  const AdminOrdersFailure(this.error);

  @override
  List<Object> get props => [error];
}
