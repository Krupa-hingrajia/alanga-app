import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../../domain/repositories/vendor_dashboard_repository.dart';
import '../models/vendor_dashboard_summary_model.dart';

class VendorDashboardRepositoryImpl implements VendorDashboardRepository {
  final ApiService _apiService;

  VendorDashboardRepositoryImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<VendorDashboardSummaryModel> getSummary() async {
    try {
      final response = await _apiService.get(ApiEndpoints.vendorDashboardSummary);
      final data = response.data['data'] as Map<String, dynamic>;
      return VendorDashboardSummaryModel.fromJson(data);
    } catch (_) {
      rethrow;
    }
  }
}
