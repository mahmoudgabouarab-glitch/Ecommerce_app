import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/repo/notifications_repo.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repo) : super(NotificationsInitial());

  final NotificationsRepo _repo;

  List<NotificationModel> _items = [];
  int unreadCount = 0;

  Future<void> load() async {
    emit(NotificationsLoading());
    final result = await _repo.getNotifications();
    result.fold(
      (failure) => emit(NotificationsFailure(failure.errorMessage)),
      (response) {
        _items = response.items;
        unreadCount = response.unreadCount;
        _emitLoaded();
      },
    );
  }

  /// Silent refresh of just the unread count (for the badge), without a spinner.
  Future<void> refreshBadge() async {
    final result = await _repo.getNotifications();
    result.fold((_) {}, (response) {
      _items = response.items;
      unreadCount = response.unreadCount;
      _emitLoaded();
    });
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    _items = _items.map((n) => n.copyAsRead()).toList();
    unreadCount = 0;
    _emitLoaded();
    final result = await _repo.markAllRead();
    result.fold((_) => load(), (_) {});
  }

  Future<void> markRead(int id) async {
    final target = _items.where((n) => n.id == id);
    if (target.isEmpty || target.first.isRead) return;
    _items = _items.map((n) => n.id == id ? n.copyAsRead() : n).toList();
    if (unreadCount > 0) unreadCount--;
    _emitLoaded();
    await _repo.markRead(id);
  }

  void reset() {
    _items = [];
    unreadCount = 0;
    emit(NotificationsInitial());
  }

  void _emitLoaded() => emit(NotificationsLoaded(List.of(_items), unreadCount));
}
