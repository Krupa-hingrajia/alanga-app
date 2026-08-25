import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../models/brand_model.dart';

abstract class BrandRemoteDataSource {
  Future<List<BrandModel>> getBrands();
  Future<BrandModel> requestBrand({
    required String name,
    String? description,
    String? logo,
  });
  Future<BrandModel> createBrand({
    required String name,
    String? description,
    String? image,
  });
  Future<BrandModel> updateBrand({
    required String id,
    required String name,
    String? description,
    String? image,
  });
  Future<void> deleteBrand(String id);
}

class BrandRemoteDataSourceImpl implements BrandRemoteDataSource {
  final ApiService _apiService;

  BrandRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<BrandModel>> getBrands() async {
    try {
      final response = await _apiService.get('/vendor/brands');
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => BrandModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<BrandModel> requestBrand({
    required String name,
    String? description,
    String? logo,
  }) async {
    try {
      final response = await _apiService.post(
        '/vendor/brands/request',
        data: {
          'name': name,
          if (description != null && description.isNotEmpty) 'description': description,
          if (logo != null && logo.isNotEmpty) 'logo': logo,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return BrandModel.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<BrandModel> createBrand({
    required String name,
    String? description,
    String? image,
  }) async {
    try {
      final response = await _apiService.post(
        '/vendor/brands',
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (image != null) 'logo': image,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return BrandModel.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<BrandModel> updateBrand({
    required String id,
    required String name,
    String? description,
    String? image,
  }) async {
    try {
      final response = await _apiService.put(
        '/vendor/brands/$id',
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (image != null) 'logo': image,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return BrandModel.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteBrand(String id) async {
    try {
      await _apiService.delete('/vendor/brands/$id');
    } on DioException {
      rethrow;
    }
  }
}
