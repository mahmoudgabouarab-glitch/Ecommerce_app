import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/notification_model.dart';

abstract class NotificationsRepo {
  Future<Either<Failure, NotificationsResponse>> getNotifications();

  Future<Either<Failure, Unit>> markAllRead();

  Future<Either<Failure, Unit>> markRead(int id);

  Future<Either<Failure, Unit>> registerDevice({
    required String token,
    String? platform,
  });

  Future<Either<Failure, Unit>> unregisterDevice(String token);
}
