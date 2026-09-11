import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository repository;

  CartCubit({required this.repository}) : super(CartInitial());

  Future<void> fetchCart() async {
    if (state is! CartLoaded) {
      emit(CartLoading());
    }
    try {
      final res = await repository.getCart();
      emit(CartLoaded(items: res.items, summary: res.summary));
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<bool> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    try {
      final res = await repository.addToCart(
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );
      emit(CartLoaded(
        items: res.items,
        summary: res.summary,
        message: 'Added to Cart',
      ));
      return true;
    } catch (e) {
      // Refresh current cart on error
      fetchCart();
      rethrow;
    }
  }

  Future<void> updateQuantity({
    required String cartItemId,
    int? quantity,
    String? action,
  }) async {
    try {
      final res = await repository.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
        action: action,
      );
      emit(CartLoaded(items: res.items, summary: res.summary));
    } catch (e) {
      fetchCart();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      final res = await repository.removeFromCart(cartItemId);
      emit(CartLoaded(
        items: res.items,
        summary: res.summary,
        message: 'Item removed from cart',
      ));
    } catch (e) {
      fetchCart();
    }
  }

  Future<void> clearCart() async {
    try {
      final res = await repository.clearCart();
      emit(CartLoaded(
        items: res.items,
        summary: res.summary,
        message: 'Cart cleared',
      ));
    } catch (e) {
      fetchCart();
    }
  }
}
