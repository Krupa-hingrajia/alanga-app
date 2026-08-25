import '../../data/models/product_model.dart';
import '../../data/models/product_image_model.dart';
import '../../data/models/product_variant_model.dart';
import '../../data/models/attribute_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct(Map<String, dynamic> data);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data);
  Future<ProductModel> deleteProduct(String id);
  Future<ProductModel> submitProduct(String id);

  // Product Image Management
  Future<List<ProductImageModel>> uploadProductImages(
    String productId,
    List<String> filePaths, {
    String? productVariantId,
    void Function(int sent, int total)? onProgress,
  });
  Future<List<ProductImageModel>> getProductImages(String productId, {String? productVariantId});
  Future<ProductImageModel> setPrimaryProductImage(String productId, String imageId, {String? productVariantId});
  Future<void> deleteProductImage(String productId, String imageId);
  Future<List<ProductImageModel>> reorderProductImages(
    String productId,
    List<Map<String, dynamic>> orders,
  );

  // Product Variant & Dynamic Attributes Management
  Future<List<AttributeModel>> fetchAttributes();
  Future<List<ProductVariantModel>> getProductVariants(String productId);
  Future<ProductVariantModel> createProductVariant(String productId, Map<String, dynamic> data);
  Future<ProductVariantModel> updateProductVariant(String productId, String variantId, Map<String, dynamic> data);
  Future<void> deleteProductVariant(String productId, String variantId);
}
