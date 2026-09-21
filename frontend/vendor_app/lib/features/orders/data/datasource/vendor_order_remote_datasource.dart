import '../../../../core/network/api_service.dart';
import '../models/vendor_order_model.dart';

abstract class VendorOrderRemoteDataSource {
  Future<List<VendorOrderModel>> getVendorOrders();
  Future<VendorOrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  });
}

class VendorOrderRemoteDataSourceImpl implements VendorOrderRemoteDataSource {
  final ApiService _apiService;

  VendorOrderRemoteDataSourceImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<List<VendorOrderModel>> getVendorOrders() async {
    final response = await _apiService.get('/vendor/orders');
    final data = response.data['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((json) => VendorOrderModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  @override
  Future<VendorOrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await _apiService.put(
      '/vendor/orders/$orderId/status',
      data: {'status': status},
    );
    final data = response.data['data'];
    return VendorOrderModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
