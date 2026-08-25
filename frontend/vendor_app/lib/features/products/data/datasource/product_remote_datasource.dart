import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../models/product_model.dart';
import '../models/product_image_model.dart';
import '../models/product_variant_model.dart';
import '../../../shipping/data/models/product_shipping_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getVendorProducts({
    String? categoryId,
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  });

  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct(Map<String, dynamic> data);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);

  Future<List<ProductImageModel>> uploadProductImages(
    String productId,
    List<String> filePaths, {
    String? productVariantId,
    void Function(int sent, int total)? onProgress,
  });

  Future<List<ProductImageModel>> getProductImages(String productId, {String? productVariantId});
  Future<ProductImageModel> setPrimaryImage(String productId, String imageId, {String? productVariantId});
  Future<void> deleteProductImage(String productId, String imageId);
  Future<List<ProductImageModel>> reorderProductImages(String productId, List<Map<String, dynamic>> orders);

  Future<List<ProductVariantModel>> getProductVariants(String productId);
  Future<ProductVariantModel> createProductVariant(String productId, Map<String, dynamic> data);
  Future<ProductVariantModel> updateProductVariant(String productId, String variantId, Map<String, dynamic> data);
  Future<void> deleteProductVariant(String productId, String variantId);

  Future<ProductShippingModel?> getProductShipping(String productId);
  Future<ProductShippingModel> saveProductShipping(String productId, Map<String, dynamic> data);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiService _apiService;

  ProductRemoteDataSourceImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<List<ProductModel>> getVendorProducts({
    String? categoryId,
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get('/vendor/products', queryParameters: queryParams);
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiService.get('/vendor/products/$id');
      return ProductModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/vendor/products', data: data);
      return ProductModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/vendor/products/$id', data: data);
      return ProductModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _apiService.delete('/vendor/products/$id');
    } on DioException {
      rethrow;
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
      final formData = FormData();
      for (final filePath in filePaths) {
        final cleanPath = filePath.startsWith('file://')
            ? filePath.replaceFirst('file://', '')
            : filePath;
        final file = await MultipartFile.fromFile(cleanPath);
        formData.files.add(MapEntry('files', file));
      }

      final url = (productVariantId != null && productVariantId.isNotEmpty)
          ? '/vendor/products/$productId/images?productVariantId=$productVariantId'
          : '/vendor/products/$productId/images';

      final response = await _apiService.post(
        url,
        data: formData,
      );

      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => ProductImageModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<ProductImageModel>> getProductImages(String productId, {String? productVariantId}) async {
    try {
      final url = (productVariantId != null && productVariantId.isNotEmpty)
          ? '/vendor/products/$productId/images?productVariantId=$productVariantId'
          : '/vendor/products/$productId/images';
      final response = await _apiService.get(url);
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => ProductImageModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductImageModel> setPrimaryImage(String productId, String imageId, {String? productVariantId}) async {
    try {
      final url = (productVariantId != null && productVariantId.isNotEmpty)
          ? '/vendor/products/$productId/images/$imageId/primary?productVariantId=$productVariantId'
          : '/vendor/products/$productId/images/$imageId/primary';
      final response = await _apiService.put(url);
      return ProductImageModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteProductImage(String productId, String imageId) async {
    try {
      await _apiService.delete('/vendor/products/$productId/images/$imageId');
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<ProductImageModel>> reorderProductImages(
      String productId, List<Map<String, dynamic>> orders) async {
    try {
      final response = await _apiService.put(
        '/vendor/products/$productId/images/reorder',
        data: {'images': orders},
      );
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => ProductImageModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<List<ProductVariantModel>> getProductVariants(String productId) async {
    try {
      final response = await _apiService.get('/vendor/products/$productId/variants');
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => ProductVariantModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductVariantModel> createProductVariant(String productId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/vendor/products/$productId/variants', data: data);
      return ProductVariantModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductVariantModel> updateProductVariant(
      String productId, String variantId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/vendor/products/$productId/variants/$variantId', data: data);
      return ProductVariantModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> deleteProductVariant(String productId, String variantId) async {
    try {
      await _apiService.delete('/vendor/products/$productId/variants/$variantId');
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductShippingModel?> getProductShipping(String productId) async {
    try {
      final response = await _apiService.get('/vendor/products/$productId/shipping');
      if (response.data['data'] == null) return null;
      return ProductShippingModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<ProductShippingModel> saveProductShipping(String productId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/vendor/products/$productId/shipping', data: data);
      return ProductShippingModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }
}
