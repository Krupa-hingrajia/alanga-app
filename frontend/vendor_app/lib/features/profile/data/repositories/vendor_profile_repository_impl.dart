import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../../domain/repositories/vendor_profile_repository.dart';
import '../models/vendor_profile_model.dart';

class VendorProfileRepositoryImpl implements VendorProfileRepository {
  final ApiService _apiService;

  VendorProfileRepositoryImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<VendorProfileModel> getProfile() async {
    try {
      final response = await _apiService.get(ApiEndpoints.vendorProfile);
      final data = response.data['data'] as Map<String, dynamic>;
      return VendorProfileModel.fromJson(data);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<VendorProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.vendorProfile,
        data: data,
      );
      final resData = response.data['data'] as Map<String, dynamic>;
      return VendorProfileModel.fromJson(resData);
    } catch (_) {
      rethrow;
    }
  }
}
