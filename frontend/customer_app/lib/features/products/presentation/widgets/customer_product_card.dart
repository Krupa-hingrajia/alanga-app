import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/utils/category_cache.dart';
import '../../../products/data/models/product_model.dart';
import '../../../wishlist/presentation/widgets/wishlist_button.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';

class CustomerProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleWishlist;
  final double width;

  const CustomerProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onToggleWishlist,
    this.width = 165,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.mrp > product.sellingPrice;
    final discountPercent = hasDiscount
        ? (((product.mrp - product.sellingPrice) / product.mrp) * 100).round()
        : 0;

    final isOutOfStock = (product.stock ?? 1) <= 0;

    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EDE8), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/products/details', extra: product);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Container & Badges
                Stack(
                  children: [
                    Container(
                      height: 125,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6FAF9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageView(
                          imageUrl: product.primaryImageUrl.isNotEmpty
                              ? product.primaryImageUrl
                              : ((product.image != null && product.image!.isNotEmpty)
                                  ? product.image
                                  : CategoryCache.getImageUrl(product.categoryId)),
                          fit: BoxFit.cover,
                          placeholderIcon: Icons.shopping_bag_outlined,
                        ),
                      ),
                    ),

                    // Discount Tag
                    if (hasDiscount && discountPercent > 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.brandRed, Color(0xFFFF5252)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$discountPercent% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),

                    // Wishlist Button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: WishlistButton(
                        productId: product.id,
                        initialIsWishlisted: product.isWishlisted ?? false,
                        size: 16,
                        padding: const EdgeInsets.all(6),
                      ),
                    ),

                    if (isOutOfStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Rating & Brand Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star_rounded, size: 11, color: Color(0xFFD97706)),
                          SizedBox(width: 2),
                          Text(
                            '4.5',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        product.brandName ?? 'ALANGA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandOrange,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Product Name
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                    height: 1.25,
                  ),
                ),
                const Spacer(),

                // Price & Add to Cart Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount)
                            Text(
                              '₹${product.mrp.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          Text(
                            '₹${product.sellingPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: isOutOfStock
                          ? null
                          : () async {
                              if (onAddToCart != null) {
                                onAddToCart!();
                                return;
                              }

                              try {
                                final defaultVariantId = product.defaultVariant?.id ??
                                    (product.variants.isNotEmpty ? product.variants.first.id : null);

                                await context.read<CartCubit>().addToCart(
                                      productId: product.id,
                                      variantId: defaultVariantId,
                                      quantity: 1,
                                    );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${product.name} added to cart',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.primaryGreen,
                                      duration: const Duration(seconds: 3),
                                      action: SnackBarAction(
                                        label: 'VIEW CART',
                                        textColor: Colors.amber,
                                        onPressed: () {
                                          context.push('/cart');
                                        },
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  final errorMsg = e.toString().replaceAll('Exception: ', '');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMsg),
                                      backgroundColor: AppColors.brandRed,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              }
                            },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isOutOfStock ? Colors.grey.shade300 : AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 14, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              isOutOfStock ? 'N/A' : 'Add',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
