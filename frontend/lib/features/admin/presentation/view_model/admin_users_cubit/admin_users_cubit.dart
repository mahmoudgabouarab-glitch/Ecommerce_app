import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/admin_user_model.dart';
import '../../../data/repo/admin_repo.dart';

part 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  AdminUsersCubit(this._repo) : super(AdminUsersInitial());

  final AdminRepo _repo;
  List<AdminUserModel> _users = [];

  Future<void> getUsers({String? search}) async {
    emit(AdminUsersLoading());
    final result = await _repo.getUsers(search: search);
    result.fold(
      (failure) => emit(AdminUsersFailure(failure.errorMessage)),
      (users) {
        _users = users;
        emit(AdminUsersLoaded(users));
      },
    );
  }

  Future<void> setRole(AdminUserModel user, String role) async {
    emit(AdminUsersLoaded(_users, updatingId: user.id));
    final result = await _repo.updateUserRole(user.id, role);
    result.fold(
      (failure) {
        emit(AdminUsersFailure(failure.errorMessage));
        emit(AdminUsersLoaded(_users));
      },
      (updated) {
        _users =
            _users.map((u) => u.id == updated.id ? updated : u).toList();
        emit(AdminUsersLoaded(_users));
      },
    );
  }

  Future<void> deleteUser(AdminUserModel user) async {
    emit(AdminUsersLoaded(_users, updatingId: user.id));
    final result = await _repo.deleteUser(user.id);
    result.fold(
      (failure) {
        emit(AdminUsersFailure(failure.errorMessage));
        emit(AdminUsersLoaded(_users));
      },
      (_) {
        _users = _users.where((u) => u.id != user.id).toList();
        emit(AdminUsersLoaded(_users));
      },
    );
  }
}
