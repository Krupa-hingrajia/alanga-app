import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiService _apiService;

  ProductRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiService.get('/customer/products');
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }
}
