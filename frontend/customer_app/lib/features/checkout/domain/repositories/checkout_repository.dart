import '../../data/models/checkout_summary_model.dart';
import '../../data/models/order_model.dart';

abstract class CheckoutRepository {
  Future<CheckoutSummaryModel> getCheckoutSummary();
  Future<OrderModel> placeOrder({
    required String addressId,
    String paymentMethod = 'COD',
    String? notes,
  });
  Future<Map<String, dynamic>> createPaymentOrder({
    required String gateway,
    required String addressId,
    String? notes,
  });
  Future<OrderModel> verifyPayment({
    required String gateway,
    required String gatewayOrderId,
    String? gatewayPaymentId,
    String? gatewaySignature,
    required String addressId,
    String? notes,
  });
  Future<List<OrderModel>> getCustomerOrders();
  Future<OrderModel> getOrderById(String orderId);
}
