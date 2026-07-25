import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/notification_model.dart';

abstract class NotificationsRepo {
  Future<Either<Failure, NotificationsResponse>> getNotifications();

  Future<Either<Failure, Unit>> markAllRead();

  Future<Either<Failure, Unit>> markRead(int id);
}
