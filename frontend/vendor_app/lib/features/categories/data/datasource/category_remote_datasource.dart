import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? image,
  });
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    String? description,
    String? image,
  });
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiService _apiService;

  CategoryRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get('/vendor/categories');
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? image,
  }) async {
    try {
      final response = await _apiService.post(
        '/vendor/categories',
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (image != null) 'image': image,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return CategoryModel.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    String? description,
    String? image,
  }) async {
    try {
      final response = await _apiService.put(
        '/vendor/categories/$id',
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (image != null) 'image': image,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return CategoryModel.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _apiService.delete('/vendor/categories/$id');
    } on DioException {
      rethrow;
    }
  }
}
