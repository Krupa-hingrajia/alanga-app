import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDatasource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> getAddressById(String id);
  Future<AddressModel> createAddress(Map<String, dynamic> data);
  Future<AddressModel> updateAddress(String id, Map<String, dynamic> data);
  Future<void> deleteAddress(String id);
  Future<AddressModel> setDefaultAddress(String id);
}

class AddressRemoteDatasourceImpl implements AddressRemoteDatasource {
  final ApiService apiService;

  AddressRemoteDatasourceImpl({required this.apiService});

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await apiService.get('/customer/addresses');
      if (response.data != null && response.data['data'] != null) {
        final list = response.data['data'] as List;
        return list
            .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e);
      throw Exception(msg);
    }
  }

  @override
  Future<AddressModel> getAddressById(String id) async {
    try {
      final response = await apiService.get('/customer/addresses/$id');
      return AddressModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> data) async {
    try {
      final response = await apiService.post('/customer/addresses', data: data);
      return AddressModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<AddressModel> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiService.put('/customer/addresses/$id', data: data);
      return AddressModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await apiService.delete('/customer/addresses/$id');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<AddressModel> setDefaultAddress(String id) async {
    try {
      final response = await apiService.patch('/customer/addresses/$id/default');
      return AddressModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data['message'] != null) {
      final raw = e.response?.data['message'];
      if (raw is List) return raw.join(', ');
      return raw.toString();
    }
    return e.message ?? 'An unexpected network error occurred.';
  }
}
