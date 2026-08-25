import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasource/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl({required CategoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      return await _remoteDataSource.getCategories();
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? image,
  }) async {
    try {
      return await _remoteDataSource.createCategory(
        name: name,
        description: description,
        image: image,
      );
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
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
      return await _remoteDataSource.updateCategory(
        id: id,
        name: name,
        description: description,
        image: image,
      );
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _remoteDataSource.deleteCategory(id);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('message')) {
        return responseData['message'] as String;
      }
    }
    return e.message ?? 'Unknown connection error';
  }
}
