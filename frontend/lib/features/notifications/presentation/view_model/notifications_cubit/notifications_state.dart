part of 'notifications_cubit.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

final class NotificationsInitial extends NotificationsState {}

final class NotificationsLoading extends NotificationsState {}

final class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> items;
  final int unreadCount;
  const NotificationsLoaded(this.items, this.unreadCount);

  @override
  List<Object> get props => [items, unreadCount];
}

final class NotificationsFailure extends NotificationsState {
  final String error;
  const NotificationsFailure(this.error);

  @override
  List<Object> get props => [error];
}
