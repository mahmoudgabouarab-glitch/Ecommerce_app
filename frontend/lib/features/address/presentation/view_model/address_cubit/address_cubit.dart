import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/address_model.dart';
import '../../../data/repo/address_repo.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit(this._repo) : super(AddressInitial());

  final AddressRepo _repo;

  Future<void> getAddresses() async {
    emit(AddressLoading());
    final result = await _repo.getAddresses();
    result.fold(
      (failure) => emit(AddressFailure(failure.errorMessage)),
      (addresses) => emit(AddressLoaded(addresses)),
    );
  }

  Future<void> save({
    int? id,
    required String fullName,
    required String phone,
    required String line1,
    required String city,
    bool isDefault = false,
  }) async {
    emit(AddressSaving());
    final result = await _repo.save(
      id: id,
      fullName: fullName,
      phone: phone,
      line1: line1,
      city: city,
      isDefault: isDefault,
    );
    result.fold(
      (failure) => emit(AddressFailure(failure.errorMessage)),
      (_) {
        emit(AddressSaved());
        getAddresses();
      },
    );
  }

  Future<void> delete(int id) async {
    final result = await _repo.delete(id);
    result.fold(
      (failure) => emit(AddressFailure(failure.errorMessage)),
      (_) => getAddresses(),
    );
  }
}
