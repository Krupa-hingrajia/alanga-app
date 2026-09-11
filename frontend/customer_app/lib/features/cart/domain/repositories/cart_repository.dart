import '../../data/models/cart_full_response_model.dart';

abstract class CartRepository {
  Future<CartFullResponseModel> getCart();
  Future<CartFullResponseModel> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  });
  Future<CartFullResponseModel> updateQuantity({
    required String cartItemId,
    int? quantity,
    String? action,
  });
  Future<CartFullResponseModel> removeFromCart(String cartItemId);
  Future<CartFullResponseModel> clearCart();
}
