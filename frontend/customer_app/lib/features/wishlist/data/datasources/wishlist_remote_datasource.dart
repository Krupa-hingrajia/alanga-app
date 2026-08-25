import '../../../../core/network/api_service.dart';
import '../models/wishlist_item_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistItemModel>> getWishlist();
  Future<Map<String, dynamic>> toggleWishlist({required String productId, String? productVariantId});
  Future<void> removeFromWishlist(String wishlistId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final ApiService apiService;

  WishlistRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    final response = await apiService.get('/customer/wishlist');
    final list = response.data['data'] as List<dynamic>;
    return list.map((item) => WishlistItemModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> toggleWishlist({required String productId, String? productVariantId}) async {
    final response = await apiService.post(
      '/customer/wishlist/toggle',
      data: {
        'productId': productId,
        if (productVariantId != null && productVariantId.isNotEmpty) 'productVariantId': productVariantId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> removeFromWishlist(String wishlistId) async {
    await apiService.delete('/customer/wishlist/$wishlistId');
  }
}
