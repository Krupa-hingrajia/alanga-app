import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/utils/category_cache.dart';
import '../../../products/data/models/product_model.dart';
import '../../../wishlist/presentation/widgets/wishlist_button.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';

class CustomerProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleWishlist;
  final double width;

  const CustomerProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onToggleWishlist,
    this.width = 168,
  });

  @override
  State<CustomerProductCard> createState() => _CustomerProductCardState();
}

class _CustomerProductCardState extends State<CustomerProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    if ((widget.product.stock ?? 1) <= 0 || _isAdding) return;

    setState(() => _isAdding = true);
    _pressController.forward().then((_) => _pressController.reverse());

    if (widget.onAddToCart != null) {
      widget.onAddToCart!();
      setState(() => _isAdding = false);
      return;
    }

    try {
      final defaultVariantId = widget.product.defaultVariant?.id ??
          (widget.product.variants.isNotEmpty ? widget.product.variants.first.id : null);

      await context.read<CartCubit>().addToCart(
            productId: widget.product.id,
            variantId: defaultVariantId,
            quantity: 1,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.product.name} added to cart',
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
              textColor: AppColors.brandYellow,
              onPressed: () => context.push('/cart'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.brandRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasDiscount = product.mrp > product.sellingPrice;
    final discountPercent = hasDiscount
        ? (((product.mrp - product.sellingPrice) / product.mrp) * 100).round()
        : 0;

    final isOutOfStock = (product.stock ?? 1) <= 0;

    return Container(
      width: widget.width,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2ECE6), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push('/products/details', extra: product);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Container & Animated Badges
                Stack(
                  children: [
                    Container(
                      height: 125,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F7F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
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

                    // Discount Tag (Logo Ribbon Ruby Gradient)
                    if (hasDiscount && discountPercent > 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppColors.brandRubyGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ribbonRuby.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$discountPercent% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Wishlist Heart Button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.88),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: WishlistButton(
                          productId: product.id,
                          initialIsWishlisted: product.isWishlisted ?? false,
                          size: 16,
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                    ),

                    if (isOutOfStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2822),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 11, color: Color(0xFFD97706)),
                          const SizedBox(width: 2),
                          Text(
                            product.averageRating > 0 ? product.averageRating.toStringAsFixed(1) : '4.5',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                          if (product.totalReviews > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              '(${product.totalReviews})',
                              style: const TextStyle(fontSize: 8, color: Color(0xFFB45309)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        product.brandName ?? 'ALANGA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandOrange,
                          letterSpacing: 0.6,
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
                    color: Color(0xFF0C2417),
                    height: 1.25,
                  ),
                ),
                const Spacer(),

                // Price & Animated Add-to-Cart Row
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
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0C2417),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Micro-Animated Add Button
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: InkWell(
                        onTap: isOutOfStock ? null : _handleAddToCart,
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                          decoration: BoxDecoration(
                            color: isOutOfStock ? Colors.grey.shade300 : const Color(0xFF1A3827),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isOutOfStock
                                ? null
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF1A3827).withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isAdding ? Icons.hourglass_empty_rounded : Icons.add_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                isOutOfStock ? 'N/A' : 'ADD',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
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
