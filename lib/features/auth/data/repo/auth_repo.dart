import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/auth_model.dart';

abstract class AuthRepo {
  Future<Either<Failure, AuthModel>> login({
    required String email,
    required String password,
  });

  /// Registers the user and triggers a verification email. Returns the email
  /// so the app can move to the verification screen (no token yet).
  Future<Either<Failure, String>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? avatarPath,
  });

  /// Confirms the emailed code and returns the authenticated session.
  Future<Either<Failure, AuthModel>> verifyEmail({
    required String email,
    required String code,
  });

  Future<Either<Failure, Unit>> resendCode(String email);

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, Unit>> forgotPassword(String email);

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
