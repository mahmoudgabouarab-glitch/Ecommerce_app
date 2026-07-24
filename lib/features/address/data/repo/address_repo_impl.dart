import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_service.dart';
import '../models/address_model.dart';
import 'address_repo.dart';

class AddressRepoImpl implements AddressRepo {
  final ApiServise _api;

  AddressRepoImpl(this._api);

  @override
  Future<Either<Failure, List<AddressModel>>> getAddresses() async {
    try {
      final data = await _api.get(endpoint: "addresses");
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, AddressModel>> save({
    int? id,
    required String fullName,
    required String phone,
    required String line1,
    required String city,
    bool isDefault = false,
  }) async {
    try {
      final body = {
        "full_name": fullName,
        "phone": phone,
        "line1": line1,
        "city": city,
        "is_default": isDefault,
      };
      final data = id == null
          ? await _api.post(endpoint: "addresses", data: body)
          : await _api.put(endpoint: "addresses/$id", data: body);
      final map = data['data'] as Map<String, dynamic>? ?? data;
      return Right(AddressModel.fromJson(map));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(int id) async {
    try {
      await _api.delete(endpoint: "addresses/$id");
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
