import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/notification_model.dart';
import 'notifications_repo.dart';

class NotificationsRepoImpl implements NotificationsRepo {
  final ApiServise _api;

  NotificationsRepoImpl(this._api);

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications() async {
    try {
      final data = await _api.get(endpoint: ApiEndpoints.notifications);
      return Right(NotificationsResponse.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() async {
    try {
      await _api.post(endpoint: ApiEndpoints.notificationsReadAll);
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> markRead(int id) async {
    try {
      await _api.patch(endpoint: ApiEndpoints.notificationRead(id));
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> registerDevice({
    required String token,
    String? platform,
  }) async {
    try {
      await _api.post(
        endpoint: ApiEndpoints.deviceTokens,
        data: {"token": token, "platform": ?platform},
      );
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> unregisterDevice(String token) async {
    try {
      await _api.delete(endpoint: ApiEndpoints.deviceTokens, data: {"token": token});
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
