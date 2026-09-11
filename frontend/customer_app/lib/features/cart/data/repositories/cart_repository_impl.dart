import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import '../models/cart_full_response_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDatasource remoteDatasource;

  CartRepositoryImpl({required this.remoteDatasource});

  @override
  Future<CartFullResponseModel> getCart() {
    return remoteDatasource.getCart();
  }

  @override
  Future<CartFullResponseModel> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) {
    return remoteDatasource.addToCart(
      productId: productId,
      variantId: variantId,
      quantity: quantity,
    );
  }

  @override
  Future<CartFullResponseModel> updateQuantity({
    required String cartItemId,
    int? quantity,
    String? action,
  }) {
    return remoteDatasource.updateQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
      action: action,
    );
  }

  @override
  Future<CartFullResponseModel> removeFromCart(String cartItemId) {
    return remoteDatasource.removeFromCart(cartItemId);
  }

  @override
  Future<CartFullResponseModel> clearCart() {
    return remoteDatasource.clearCart();
  }
}
