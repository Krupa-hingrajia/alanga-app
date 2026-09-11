import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../models/cart_full_response_model.dart';

abstract class CartRemoteDatasource {
  Future<CartFullResponseModel> getCart();
  Future<CartFullResponseModel> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  });
  Future<CartFullResponseModel> updateQuantity({
    required String cartItemId,
    int? quantity,
    String? action,
  });
  Future<CartFullResponseModel> removeFromCart(String cartItemId);
  Future<CartFullResponseModel> clearCart();
}

class CartRemoteDatasourceImpl implements CartRemoteDatasource {
  final ApiService apiService;

  CartRemoteDatasourceImpl({required this.apiService});

  @override
  Future<CartFullResponseModel> getCart() async {
    final response = await apiService.get('/customer/cart');
    if (response.data != null && response.data['data'] != null) {
      return CartFullResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }
    return CartFullResponseModel.empty();
  }

  @override
  Future<CartFullResponseModel> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    final validQuantity = quantity >= 1 ? quantity : 1;
    final payload = <String, dynamic>{
      'productId': productId,
      if (variantId != null && variantId.isNotEmpty) 'variantId': variantId,
      if (variantId != null && variantId.isNotEmpty) 'productVariantId': variantId,
      'quantity': validQuantity,
    };

    debugPrint('================ [ADD TO CART REQUEST] ================');
    debugPrint('--> POST /customer/cart');
    debugPrint('--> Product ID: $productId');
    debugPrint('--> Variant ID: $variantId');
    debugPrint('--> Quantity: $validQuantity');
    debugPrint('--> Complete Payload: $payload');

    try {
      final response = await apiService.post('/customer/cart', data: payload);

      debugPrint('================ [ADD TO CART RESPONSE] ================');
      debugPrint('<-- Status Code: ${response.statusCode}');
      debugPrint('<-- Response Body: ${response.data}');

      if (response.data != null && response.data['data'] != null) {
        return CartFullResponseModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      return CartFullResponseModel.empty();
    } on DioException catch (e) {
      debugPrint('================ [ADD TO CART DIO EXCEPTION] ================');
      debugPrint('<-- Status Code: ${e.response?.statusCode}');
      debugPrint('<-- Response Error Body: ${e.response?.data}');

      String message = 'Failed to add product to cart.';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        final rawMsg = e.response?.data['message'];
        if (rawMsg is List) {
          message = rawMsg.join(', ');
        } else {
          message = rawMsg.toString();
        }
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }

      throw Exception(message);
    } catch (e) {
      debugPrint('================ [ADD TO CART UNKNOWN EXCEPTION] ================');
      debugPrint('Error: $e');
      throw Exception(e.toString());
    }
  }

  @override
  Future<CartFullResponseModel> updateQuantity({
    required String cartItemId,
    int? quantity,
    String? action,
  }) async {
    final body = <String, dynamic>{};
    if (quantity != null) body['quantity'] = quantity;
    if (action != null) body['action'] = action;

    final response = await apiService.put(
      '/customer/cart/$cartItemId',
      data: body,
    );
    if (response.data != null && response.data['data'] != null) {
      return CartFullResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }
    return CartFullResponseModel.empty();
  }

  @override
  Future<CartFullResponseModel> removeFromCart(String cartItemId) async {
    final response = await apiService.delete('/customer/cart/$cartItemId');
    if (response.data != null && response.data['data'] != null) {
      return CartFullResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }
    return CartFullResponseModel.empty();
  }

  @override
  Future<CartFullResponseModel> clearCart() async {
    final response = await apiService.delete('/customer/cart');
    if (response.data != null && response.data['data'] != null) {
      return CartFullResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }
    return CartFullResponseModel.empty();
  }
}
