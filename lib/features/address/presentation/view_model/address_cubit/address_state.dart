part of 'address_cubit.dart';

sealed class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object> get props => [];
}

final class AddressInitial extends AddressState {}

final class AddressLoading extends AddressState {}

final class AddressSaving extends AddressState {}

final class AddressSaved extends AddressState {}

final class AddressLoaded extends AddressState {
  final List<AddressModel> addresses;
  const AddressLoaded(this.addresses);

  @override
  List<Object> get props => [addresses];
}

final class AddressFailure extends AddressState {
  final String error;
  const AddressFailure(this.error);

  @override
  List<Object> get props => [error];
}
