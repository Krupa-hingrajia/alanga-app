import '../../data/models/address_model.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final String? message;

  AddressLoaded({
    required this.addresses,
    this.selectedAddress,
    this.message,
  });
}

class AddressError extends AddressState {
  final String message;

  AddressError({required this.message});
}
