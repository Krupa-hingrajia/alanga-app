import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/models/product_variant_model.dart';
import '../../data/models/wishlist_item_model.dart';

class WishlistCard extends StatefulWidget {
  final WishlistItemModel item;
  final VoidCallback onRemove;
  final Function(ProductVariantModel selectedVariant) onMoveToCart;
  final Function(ProductVariantModel newVariant)? onVariantChanged;
  final VoidCallback onTap;

  const WishlistCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onMoveToCart,
    this.onVariantChanged,
    required this.onTap,
  });

  @override
  State<WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<WishlistCard> {
  late ProductVariantModel? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.item.selectedVariant ??
        (widget.item.product.variants.isNotEmpty ? widget.item.product.variants.first : null);
  }

  @override
  void didUpdateWidget(covariant WishlistCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.selectedVariant != widget.item.selectedVariant) {
      setState(() {
        _selectedVariant = widget.item.selectedVariant ??
            (widget.item.product.variants.isNotEmpty ? widget.item.product.variants.first : null);
      });
    }
  }

  String _getVariantImageUrl(ProductModel product, ProductVariantModel? variant) {
    if (variant != null) {
      if (variant.images.isNotEmpty) {
        final primary = variant.images.firstWhere(
          (img) => img.isPrimary,
          orElse: () => variant.images.first,
        );
        if (primary.imageUrl.isNotEmpty) return primary.imageUrl;
      }

      final matchingImgs = product.images
          .where((img) => img.productVariantId == variant.id)
          .toList();
      if (matchingImgs.isNotEmpty) {
        final primary = matchingImgs.firstWhere(
          (img) => img.isPrimary,
          orElse: () => matchingImgs.first,
        );
        if (primary.imageUrl.isNotEmpty) return primary.imageUrl;
      }
    }

    return product.primaryImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.item.product;
    final shipping = widget.item.shipping;
    final variants = product.variants;

    final image = _getVariantImageUrl(product, _selectedVariant);

    final price = _selectedVariant != null ? _selectedVariant!.price : widget.item.sellingPrice;
    final mrp = widget.item.mrp > price ? widget.item.mrp : price;
    final discount = (mrp > price && mrp > 0) ? (((mrp - price) / mrp) * 100).round() : 0;

    final stockCount = _selectedVariant != null ? _selectedVariant!.stock : (product.stock ?? 0);
    final isOutOfStock = stockCount <= 0;
    final isLowStock = stockCount > 0 && stockCount <= 5;

    Color stockColor = AppColors.primaryGreen;
    String stockText = 'In Stock';
    if (isOutOfStock) {
      stockColor = AppColors.brandRed;
      stockText = 'Out of Stock';
    } else if (isLowStock) {
      stockColor = AppColors.brandOrange;
      stockText = 'Low Stock ($stockCount left)';
    }

    final isFreeShipping = shipping?.isFreeShipping ?? (shipping?.shippingCharge == 0);
    final shippingText = shipping != null
        ? (isFreeShipping ? 'FREE Delivery' : '₹${shipping.shippingCharge.toStringAsFixed(0)} Delivery')
        : 'Standard Shipping';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4ECE8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Image & Metadata
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Frame
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFCFA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE4ECE8)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CustomImageView(
                      imageUrl: image,
                      fit: BoxFit.contain,
                      placeholderIcon: Icons.shopping_bag_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand & Category
                      Row(
                        children: [
                          if (widget.item.brandName != null && widget.item.brandName!.isNotEmpty) ...[
                            Text(
                              widget.item.brandName!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A9A86),
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (widget.item.categoryName != null) ...[
                              const Text(' • ', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              Text(
                                widget.item.categoryName!,
                                style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                              ),
                            ],
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (mrp > price) ...[
                            Text(
                              '₹${mrp.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($discount% OFF)',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandRed,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Stock & Shipping Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: stockColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stockText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: stockColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.local_shipping_outlined, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 3),
                          Text(
                            shippingText,
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Inline Variant Selector Bar (If product has variants)
            if (variants.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FAF7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2ECE5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.style_outlined, size: 13, color: AppColors.primaryGreen),
                        const SizedBox(width: 4),
                        const Text(
                          'Select Variant:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const Spacer(),
                        if (_selectedVariant != null)
                          Text(
                            _selectedVariant!.variantName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: variants.map((v) {
                          final isSelected = _selectedVariant?.id == v.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedVariant = v;
                                });
                                widget.onVariantChanged?.call(v);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryGreen : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryGreen : const Color(0xFFCBDCD1),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      const Icon(Icons.check, size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      v.variantName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.white : const Color(0xFF2C4435),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F4F1)),
            const SizedBox(height: 10),

            // Action Buttons Row (Remove & Move to Cart)
            Row(
              children: [
                // Remove Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text(
                      'REMOVE',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandRed,
                      side: const BorderSide(color: Color(0xFFFFCDD2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Move to Cart Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isOutOfStock
                        ? null
                        : () {
                            if (_selectedVariant != null) {
                              widget.onMoveToCart(_selectedVariant!);
                            } else if (variants.isNotEmpty) {
                              widget.onMoveToCart(variants.first);
                            }
                          },
                    icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                    label: Text(
                      isOutOfStock ? 'OUT OF STOCK' : 'MOVE TO CART',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3827),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE4ECE8),
                      disabledForegroundColor: Colors.grey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
