import '../../data/models/product_shipping_model.dart';

abstract class ShippingRepository {
  Future<ProductShippingModel?> getShipping(String productId);
  Future<ProductShippingModel> saveShipping(String productId, ProductShippingModel model);
}
