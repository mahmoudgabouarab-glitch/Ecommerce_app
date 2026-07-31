import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/genie_message.dart';

abstract class GenieRepo {
  Future<Either<Failure, GenieReply>> chat(List<Map<String, String>> messages);
}
