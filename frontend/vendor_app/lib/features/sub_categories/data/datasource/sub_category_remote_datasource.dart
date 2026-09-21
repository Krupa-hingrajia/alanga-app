import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../models/sub_category_model.dart';

abstract class SubCategoryRemoteDataSource {
  Future<List<SubCategoryModel>> getSubCategories({String? categoryId});
  Future<SubCategoryModel> createSubCategory({
    required String categoryId,
    required String name,
    String? description,
    String? image,
  });
  Future<SubCategoryModel> updateSubCategory({
    required String id,
    required String categoryId,
    required String name,
    String? description,
    String? image,
  });
  Future<void> deleteSubCategory(String id);
}

class SubCategoryRemoteDataSourceImpl implements SubCategoryRemoteDataSource {
  final ApiService _apiService;

  SubCategoryRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<SubCategoryModel>> getSubCategories({String? categoryId}) async {
    try {
      final response = await _apiService.get(
        '/vendor/sub-categories',
        queryParameters: categoryId != null ? {'categoryId': categoryId} : null,
      );
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => SubCategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<SubCategoryModel> createSubCategory({
    required String categoryId,
    required String name,
    String? description,
    String? image,
  }) async {
    try {
      final response = await _apiService.post(
        '/vendor/sub-categories',
        data: {
          'categoryId': categoryId,
          'name': name,
          if (description != null) 'description': description,
          if (image != null) 'image': image,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return SubCategoryModel.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<SubCategoryModel> updateSubCategory({
    required String id,
    required String categoryId,
    required String name,
    String? description,
    String? image,
  }) async {
    try {
      final response = await _apiService.put(
        '/vendor/sub-categories/$id',
        data: {
          'categoryId': categoryId,
          'name': name,
          if (description != null) 'description': description,
          if (image != null) 'image': image,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return SubCategoryModel.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteSubCategory(String id) async {
    try {
      await _apiService.delete('/vendor/sub-categories/$id');
    } on DioException {
      rethrow;
    }
  }
}
