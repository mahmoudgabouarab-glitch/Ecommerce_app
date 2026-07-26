import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_service.dart';
import '../../../auth/data/models/auth_model.dart';
import 'profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ApiServise _api;

  ProfileRepoImpl(this._api);

  @override
  Future<Either<Failure, UserModel>> updateProfile({
    required String name,
    String? phone,
    bool? showPhone,
    String? gender,
    String? birthDate,
    String? bio,
    String? avatarPath,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'phone': phone ?? '',
        'show_phone': (showPhone ?? false) ? 1 : 0,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (birthDate != null && birthDate.isNotEmpty) 'birth_date': birthDate,
        'bio': bio ?? '',
        if (avatarPath != null)
          'avatar': await MultipartFile.fromFile(avatarPath),
      };
      // ApiServise auto-wraps in FormData when a MultipartFile is present.
      final res = await _api.post(endpoint: 'profile', data: data);
      final map = res['data'] as Map<String, dynamic>? ?? res;
      return Right(UserModel.fromJson(map));
    } catch (e) {
      if (e is DioException) return Left(ServiseFailure.fromDioException(e));
      return Left(ServiseFailure(e.toString()));
    }
  }
}
