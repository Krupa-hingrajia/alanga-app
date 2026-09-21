import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/sub_category_repository.dart';
import '../datasource/sub_category_remote_datasource.dart';
import '../models/sub_category_model.dart';

class SubCategoryRepositoryImpl implements SubCategoryRepository {
  final SubCategoryRemoteDataSource _remoteDataSource;

  SubCategoryRepositoryImpl({required SubCategoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SubCategoryModel>> getSubCategories({String? categoryId}) async {
    try {
      return await _remoteDataSource.getSubCategories(categoryId: categoryId);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
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
      return await _remoteDataSource.createSubCategory(
        categoryId: categoryId,
        name: name,
        description: description,
        image: image,
      );
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
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
      return await _remoteDataSource.updateSubCategory(
        id: id,
        categoryId: categoryId,
        name: name,
        description: description,
        image: image,
      );
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<void> deleteSubCategory(String id) async {
    try {
      await _remoteDataSource.deleteSubCategory(id);
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
