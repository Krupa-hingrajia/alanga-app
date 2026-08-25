import '../../data/models/wishlist_item_model.dart';

abstract class WishlistRepository {
  Future<List<WishlistItemModel>> getWishlist();
  Future<Map<String, dynamic>> toggleWishlist({required String productId, String? productVariantId});
  Future<void> removeFromWishlist(String wishlistId);
}
