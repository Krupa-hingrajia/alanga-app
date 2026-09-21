import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasource/product_remote_datasource.dart';
import '../models/product_model.dart';
import '../models/brand_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      return await _remoteDataSource.getProducts();
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      return await _remoteDataSource.getProductById(id);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    try {
      return await _remoteDataSource.getBrands();
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
