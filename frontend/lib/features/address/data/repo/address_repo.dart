import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/address_model.dart';

abstract class AddressRepo {
  Future<Either<Failure, List<AddressModel>>> getAddresses();

  Future<Either<Failure, AddressModel>> save({
    int? id,
    required String fullName,
    required String phone,
    required String line1,
    required String city,
    bool isDefault = false,
  });

  Future<Either<Failure, Unit>> delete(int id);
}
