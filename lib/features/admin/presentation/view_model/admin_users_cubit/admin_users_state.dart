part of 'admin_users_cubit.dart';

sealed class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];
}

final class AdminUsersInitial extends AdminUsersState {}

final class AdminUsersLoading extends AdminUsersState {}

final class AdminUsersLoaded extends AdminUsersState {
  final List<AdminUserModel> users;
  final int? updatingId; // id of the row whose role is being changed

  const AdminUsersLoaded(this.users, {this.updatingId});

  @override
  List<Object?> get props => [users, updatingId];
}

final class AdminUsersFailure extends AdminUsersState {
  final String error;
  const AdminUsersFailure(this.error);

  @override
  List<Object?> get props => [error];
}
