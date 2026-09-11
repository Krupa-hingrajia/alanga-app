import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/address_repository.dart';
import '../../data/models/address_model.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;

  AddressCubit({required this.repository}) : super(AddressInitial());

  Future<void> fetchAddresses({String? autoSelectId}) async {
    emit(AddressLoading());
    try {
      final addresses = await repository.getAddresses();
      AddressModel? selected;

      if (autoSelectId != null) {
        selected = addresses.firstWhere(
          (a) => a.id == autoSelectId,
          orElse: () => addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first),
        );
      } else if (addresses.isNotEmpty) {
        selected = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
      }

      emit(AddressLoaded(addresses: addresses, selectedAddress: selected));
    } catch (e) {
      emit(AddressError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void selectAddress(AddressModel address) {
    if (state is AddressLoaded) {
      final current = state as AddressLoaded;
      emit(AddressLoaded(
        addresses: current.addresses,
        selectedAddress: address,
      ));
    }
  }

  Future<void> createAddress(Map<String, dynamic> data) async {
    try {
      final created = await repository.createAddress(data);
      await fetchAddresses(autoSelectId: created.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      await repository.updateAddress(id, data);
      await fetchAddresses(autoSelectId: id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await repository.deleteAddress(id);
      await fetchAddresses();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      await repository.setDefaultAddress(id);
      await fetchAddresses(autoSelectId: id);
    } catch (e) {
      rethrow;
    }
  }
}
