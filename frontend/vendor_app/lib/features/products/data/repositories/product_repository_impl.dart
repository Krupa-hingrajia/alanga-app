import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasource/product_remote_datasource.dart';
import '../models/product_model.dart';
import '../models/product_image_model.dart';
import '../models/product_variant_model.dart';
import '../models/attribute_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      return await _remoteDataSource.getVendorProducts();
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
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      return await _remoteDataSource.createProduct(data);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      return await _remoteDataSource.updateProduct(id, data);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<ProductModel> deleteProduct(String id) async {
    try {
      await _remoteDataSource.deleteProduct(id);
      return await _remoteDataSource.getProductById(id);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<ProductModel> submitProduct(String id) async {
    try {
      return await _remoteDataSource.updateProduct(id, {'status': 'ACTIVE'});
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<List<ProductImageModel>> uploadProductImages(
    String productId,
    List<String> filePaths, {
    String? productVariantId,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      return await _remoteDataSource.uploadProductImages(
        productId,
        filePaths,
        productVariantId: productVariantId,
        onProgress: onProgress,
      );
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<List<ProductImageModel>> getProductImages(String productId, {String? productVariantId}) async {
    try {
      return await _remoteDataSource.getProductImages(productId, productVariantId: productVariantId);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<ProductImageModel> setPrimaryProductImage(String productId, String imageId, {String? productVariantId}) async {
    try {
      return await _remoteDataSource.setPrimaryImage(productId, imageId, productVariantId: productVariantId);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<void> deleteProductImage(String productId, String imageId) async {
    try {
      await _remoteDataSource.deleteProductImage(productId, imageId);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<List<ProductImageModel>> reorderProductImages(
    String productId,
    List<Map<String, dynamic>> orders,
  ) async {
    try {
      return await _remoteDataSource.reorderProductImages(productId, orders);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<List<AttributeModel>> fetchAttributes() async {
    try {
      return [];
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<List<ProductVariantModel>> getProductVariants(String productId) async {
    try {
      return await _remoteDataSource.getProductVariants(productId);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<ProductVariantModel> createProductVariant(String productId, Map<String, dynamic> data) async {
    try {
      return await _remoteDataSource.createProductVariant(productId, data);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<ProductVariantModel> updateProductVariant(String productId, String variantId, Map<String, dynamic> data) async {
    try {
      return await _remoteDataSource.updateProductVariant(productId, variantId, data);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  @override
  Future<void> deleteProductVariant(String productId, String variantId) async {
    try {
      await _remoteDataSource.deleteProductVariant(productId, variantId);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final responseData = e.response?.data;
      if (responseData is Map) {
        if (responseData.containsKey('errors') &&
            responseData['errors'] is List &&
            (responseData['errors'] as List).isNotEmpty) {
          final errList = responseData['errors'] as List;
          final details = errList.map((err) {
            if (err is Map) {
              final field = err['field'] ?? '';
              final msgs = err['messages'] is List
                  ? (err['messages'] as List).join(', ')
                  : err['message'] ?? '';
              return field.isNotEmpty ? '$field: $msgs' : msgs.toString();
            }
            return err.toString();
          }).join('; ');
          if (details.isNotEmpty) return details;
        }
        if (responseData.containsKey('message') && responseData['message'] != null) {
          return responseData['message'].toString();
        }
      }
    }
    return e.message ?? 'Unknown connection error';
  }
}
