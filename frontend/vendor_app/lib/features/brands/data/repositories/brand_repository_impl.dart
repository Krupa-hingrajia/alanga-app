import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/brand_repository.dart';
import '../datasource/brand_remote_datasource.dart';
import '../models/brand_model.dart';

class BrandRepositoryImpl implements BrandRepository {
  final BrandRemoteDataSource _remoteDataSource;

  BrandRepositoryImpl({required BrandRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<BrandModel>> getBrands() async {
    try {
      return await _remoteDataSource.getBrands();
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<BrandModel> requestBrand({
    required String name,
    String? description,
    String? logo,
  }) async {
    try {
      return await _remoteDataSource.requestBrand(
        name: name,
        description: description,
        logo: logo,
      );
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<BrandModel> createBrand({
    required String name,
    String? description,
    String? image,
  }) async {
    try {
      return await _remoteDataSource.createBrand(
        name: name,
        description: description,
        image: image,
      );
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
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
      return await _remoteDataSource.updateBrand(
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
  Future<void> deleteBrand(String id) async {
    try {
      await _remoteDataSource.deleteBrand(id);
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
