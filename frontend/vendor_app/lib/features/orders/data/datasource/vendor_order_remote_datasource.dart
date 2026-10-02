import '../../../../core/network/api_service.dart';
import '../models/vendor_order_model.dart';

abstract class VendorOrderRemoteDataSource {
  Future<List<VendorOrderModel>> getVendorOrders();
  Future<VendorOrderModel> updateOrderStatus({
    required String orderId,
    required String status,
    String? courierName,
    String? trackingNumber,
    String? trackingUrl,
    String? cancelReason,
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
    String? courierName,
    String? trackingNumber,
    String? trackingUrl,
    String? cancelReason,
  }) async {
    final payload = <String, dynamic>{'status': status};
    if (courierName != null && courierName.trim().isNotEmpty) {
      payload['courierName'] = courierName.trim();
    }
    if (trackingNumber != null && trackingNumber.trim().isNotEmpty) {
      payload['trackingNumber'] = trackingNumber.trim();
    }
    if (trackingUrl != null && trackingUrl.trim().isNotEmpty) {
      payload['trackingUrl'] = trackingUrl.trim();
    }
    if (cancelReason != null && cancelReason.trim().isNotEmpty) {
      payload['cancelReason'] = cancelReason.trim();
    }

    final response = await _apiService.put(
      '/vendor/orders/$orderId/status',
      data: payload,
    );
    final data = response.data['data'];
    return VendorOrderModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
