import '../../../../core/network/api_service.dart';
import '../models/product_shipping_model.dart';

abstract class ShippingRemoteDataSource {
  Future<ProductShippingModel?> getShipping(String productId);
  Future<ProductShippingModel> saveShipping(String productId, ProductShippingModel model);
}

class ShippingRemoteDataSourceImpl implements ShippingRemoteDataSource {
  final ApiService _apiService;

  ShippingRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<ProductShippingModel?> getShipping(String productId) async {
    try {
      final response = await _apiService.get('/vendor/products/$productId/shipping');
      if (response.data['data'] != null) {
        return ProductShippingModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      // Return null if shipping config is not found (404)
      return null;
    }
  }

  @override
  Future<ProductShippingModel> saveShipping(String productId, ProductShippingModel model) async {
    final payload = model.toJson();
    final response = await _apiService.put(
      '/vendor/products/$productId/shipping',
      data: payload,
    );

    return ProductShippingModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
