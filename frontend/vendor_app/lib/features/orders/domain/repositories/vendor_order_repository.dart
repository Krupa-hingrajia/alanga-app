import '../../data/models/vendor_order_model.dart';

abstract class VendorOrderRepository {
  Future<List<VendorOrderModel>> getOrders();
  Future<VendorOrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
