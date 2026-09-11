import '../../data/models/address_model.dart';

abstract class AddressRepository {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> getAddressById(String id);
  Future<AddressModel> createAddress(Map<String, dynamic> data);
  Future<AddressModel> updateAddress(String id, Map<String, dynamic> data);
  Future<void> deleteAddress(String id);
  Future<AddressModel> setDefaultAddress(String id);
}
