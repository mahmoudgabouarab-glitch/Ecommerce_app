import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/auth_model.dart';

/// Contract for authentication operations.
abstract class AuthRepo {
  Future<Either<Failure, AuthModel>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? avatarPath,
  });

  Future<Either<Failure, Unit>> logout();

  /// Request a reset code. Returns the OTP (demo returns it directly).
  Future<Either<Failure, String>> forgotPassword(String email);

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String otp,
    required String password,
  });

  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String password,
  });
}
