import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';
import '../models/wishlist_item_model.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;

  WishlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    return await remoteDataSource.getWishlist();
  }

  @override
  Future<Map<String, dynamic>> toggleWishlist({required String productId, String? productVariantId}) async {
    return await remoteDataSource.toggleWishlist(productId: productId, productVariantId: productVariantId);
  }

  @override
  Future<void> removeFromWishlist(String wishlistId) async {
    await remoteDataSource.removeFromWishlist(wishlistId);
  }
}
