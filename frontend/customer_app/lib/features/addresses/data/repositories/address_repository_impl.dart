import '../../data/datasources/address_remote_datasource.dart';
import '../../data/models/address_model.dart';
import '../../domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDatasource remoteDatasource;

  AddressRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<AddressModel>> getAddresses() => remoteDatasource.getAddresses();

  @override
  Future<AddressModel> getAddressById(String id) => remoteDatasource.getAddressById(id);

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> data) =>
      remoteDatasource.createAddress(data);

  @override
  Future<AddressModel> updateAddress(String id, Map<String, dynamic> data) =>
      remoteDatasource.updateAddress(id, data);

  @override
  Future<void> deleteAddress(String id) => remoteDatasource.deleteAddress(id);

  @override
  Future<AddressModel> setDefaultAddress(String id) =>
      remoteDatasource.setDefaultAddress(id);
}
