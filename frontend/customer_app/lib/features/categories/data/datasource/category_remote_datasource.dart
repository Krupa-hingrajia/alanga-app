import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiService _apiService;

  CategoryRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get('/customer/categories');
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }
}
