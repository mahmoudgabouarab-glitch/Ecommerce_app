import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../auth/data/models/auth_model.dart';

abstract class ProfileRepo {
  Future<Either<Failure, UserModel>> updateProfile({
    required String name,
    String? phone,
    String? gender,
    String? birthDate,
    String? bio,
    String? avatarPath, // local file path, null = keep current
  });
}
