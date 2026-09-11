import '../../data/models/checkout_summary_model.dart';
import '../../data/models/order_model.dart';

abstract class CheckoutRepository {
  Future<CheckoutSummaryModel> getCheckoutSummary();
  Future<OrderModel> placeOrder({
    required String addressId,
    String paymentMethod = 'COD',
    String? notes,
  });
  Future<List<OrderModel>> getCustomerOrders();
  Future<OrderModel> getOrderById(String orderId);
}
