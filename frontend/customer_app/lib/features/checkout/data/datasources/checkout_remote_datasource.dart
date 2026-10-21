import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_service.dart';
import '../models/checkout_summary_model.dart';
import '../models/order_model.dart';

abstract class CheckoutRemoteDatasource {
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

class CheckoutRemoteDatasourceImpl implements CheckoutRemoteDatasource {
  final ApiService apiService;

  CheckoutRemoteDatasourceImpl({required this.apiService});

  @override
  Future<CheckoutSummaryModel> getCheckoutSummary() async {
    try {
      final response = await apiService.get('/customer/checkout');
      if (response.data != null && response.data['data'] != null) {
        return CheckoutSummaryModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception('Failed to load checkout summary.');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<OrderModel> placeOrder({
    required String addressId,
    String paymentMethod = 'COD',
    String? notes,
  }) async {
    final payload = {
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    debugPrint('================ [PLACE ORDER REQUEST] ================');
    debugPrint('Payload: $payload');

    try {
      final response = await apiService.post('/customer/orders', data: payload);
      debugPrint('================ [PLACE ORDER RESPONSE] ================');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.data}');

      if (response.data != null && response.data['data'] != null) {
        return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to place order.');
    } on DioException catch (e) {
      debugPrint('================ [PLACE ORDER DIO EXCEPTION] ================');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Error Body: ${e.response?.data}');
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> createPaymentOrder({
    required String gateway,
    required String addressId,
    String? notes,
  }) async {
    try {
      final payload = {
        'gateway': gateway,
        'addressId': addressId,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      };
      final response = await apiService.post('/payments/create-order', data: payload);
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to initialize online payment session.');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<OrderModel> verifyPayment({
    required String gateway,
    required String gatewayOrderId,
    String? gatewayPaymentId,
    String? gatewaySignature,
    required String addressId,
    String? notes,
  }) async {
    try {
      final payload = {
        'gateway': gateway,
        'gatewayOrderId': gatewayOrderId,
        'gatewayPaymentId': ?gatewayPaymentId,
        'gatewaySignature': ?gatewaySignature,
        'addressId': addressId,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      };
      final response = await apiService.post('/payments/verify', data: payload);
      if (response.data != null && response.data['data'] != null) {
        return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Payment verified but order could not be retrieved.');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<List<OrderModel>> getCustomerOrders() async {
    try {
      final response = await apiService.get('/customer/orders');
      if (response.data != null && response.data['data'] != null) {
        final list = response.data['data'] as List;
        return list
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await apiService.get('/customer/orders/$orderId');
      if (response.data != null && response.data['data'] != null) {
        return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Order not found.');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Network Error: Please check your internet connection and try again.';
    }
    if (e.response?.data != null && e.response?.data['message'] != null) {
      final raw = e.response?.data['message'];
      if (raw is List) return raw.join(', ');
      return raw.toString();
    }
    return e.message ?? 'An unexpected network error occurred.';
  }
}
