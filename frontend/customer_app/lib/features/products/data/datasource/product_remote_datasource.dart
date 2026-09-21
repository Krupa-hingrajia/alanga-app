import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../models/product_model.dart';
import '../models/brand_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<List<BrandModel>> getBrands();
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

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiService.get('/customer/products/$id');
      return ProductModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    try {
      final response = await _apiService.get('/customer/brands');
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => BrandModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }
}
