import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_service.dart';
import '../models/notification_model.dart';
import 'notifications_repo.dart';

class NotificationsRepoImpl implements NotificationsRepo {
  final ApiServise _api;

  NotificationsRepoImpl(this._api);

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications() async {
    try {
      final data = await _api.get(endpoint: "notifications");
      return Right(NotificationsResponse.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() async {
    try {
      await _api.post(endpoint: "notifications/read-all");
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> markRead(int id) async {
    try {
      await _api.patch(endpoint: "notifications/$id/read");
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  Failure _handle(Object e) {
    if (e is DioException) return ServiseFailure.fromDioException(e);
    return ServiseFailure(e.toString());
  }
}
