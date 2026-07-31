import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_service.dart';
import '../models/genie_message.dart';
import 'genie_repo.dart';

class GenieRepoImpl implements GenieRepo {
  final ApiServise _api;

  GenieRepoImpl(this._api);

  @override
  Future<Either<Failure, GenieReply>> chat(
      List<Map<String, String>> messages) async {
    try {
      final data = await _api.post(
        endpoint: "genie/chat",
        data: {"messages": messages},
      );
      return Right(GenieReply.fromJson(data));
    } catch (e) {
      if (e is DioException) return Left(ServiseFailure.fromDioException(e));
      return Left(ServiseFailure(e.toString()));
    }
  }
}
