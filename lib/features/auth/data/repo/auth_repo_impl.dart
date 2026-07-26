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
    } on DioException catch (e) {
      final r = e.response;
      if (r?.statusCode == 403 &&
          r?.data is Map &&
          (r!.data as Map)['needs_verification'] == true) {
        final map = r.data as Map;
        return Left(EmailNotVerifiedFailure(
          (map['message'] as String?) ?? 'Please verify your email.',
          (map['email'] as String?) ?? email,
        ));
      }
      return Left(_handle(e));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, String>> register({
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
      return Right((data['email'] as String?) ?? email);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, AuthModel>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final data = await _api.post(
        endpoint: "email/verify",
        data: {"email": email, "code": code},
      );
      return Right(AuthModel.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendCode(String email) async {
    try {
      await _api.post(endpoint: "email/resend", data: {"email": email});
      return const Right(unit);
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
  Future<Either<Failure, Unit>> forgotPassword(String email) async {
    try {
      await _api.post(endpoint: "password/forgot", data: {"email": email});
      return const Right(unit);
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
