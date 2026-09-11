import '../datasources/checkout_remote_datasource.dart';
import '../models/checkout_summary_model.dart';
import '../models/order_model.dart';
import '../../domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDatasource remoteDatasource;

  CheckoutRepositoryImpl({required this.remoteDatasource});

  @override
  Future<CheckoutSummaryModel> getCheckoutSummary() =>
      remoteDatasource.getCheckoutSummary();

  @override
  Future<OrderModel> placeOrder({
    required String addressId,
    String paymentMethod = 'COD',
    String? notes,
  }) =>
      remoteDatasource.placeOrder(
        addressId: addressId,
        paymentMethod: paymentMethod,
        notes: notes,
      );

  @override
  Future<List<OrderModel>> getCustomerOrders() =>
      remoteDatasource.getCustomerOrders();

  @override
  Future<OrderModel> getOrderById(String orderId) =>
      remoteDatasource.getOrderById(orderId);
}
