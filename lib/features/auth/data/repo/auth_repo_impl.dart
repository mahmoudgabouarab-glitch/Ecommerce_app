import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_service.dart';
import '../models/auth_model.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final ApiServise _api;

  AuthRepoImpl(this._api);

  @override
  Future<Either<Failure, AuthModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _api.post(
        endpoint: "login",
        data: {"email": email, "password": password},
      );
      return Right(AuthModel.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, AuthModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? avatarPath,
  }) async {
    try {
      final data = await _api.post(
        endpoint: "register",
        data: {
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
          if (phone != null && phone.isNotEmpty) "phone": phone,
          if (avatarPath != null) "avatar": await MultipartFile.fromFile(avatarPath),
        },
      );
      return Right(AuthModel.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _api.post(endpoint: "logout");
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    try {
      final data = await _api.post(
        endpoint: "password/forgot",
        data: {"email": email},
      );
      return Right(data['otp'] as String? ?? '');
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      await _api.post(
        endpoint: "password/reset",
        data: {
          "email": email,
          "otp": otp,
          "password": password,
          "password_confirmation": password,
        },
      );
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String password,
  }) async {
    try {
      await _api.post(
        endpoint: "password/change",
        data: {
          "current_password": currentPassword,
          "password": password,
          "password_confirmation": password,
        },
      );
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
