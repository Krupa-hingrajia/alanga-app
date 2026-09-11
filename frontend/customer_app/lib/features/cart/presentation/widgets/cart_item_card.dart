import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../data/models/cart_item_model.dart';
import '../bloc/cart_cubit.dart';
import '../../../wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../../wishlist/presentation/bloc/wishlist_event.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isMaxQuantity = item.quantity >= item.stock;

    Color stockBadgeColor = AppColors.primaryGreen;
    String stockBadgeText = 'In Stock';
    if (item.stock <= 0) {
      stockBadgeColor = AppColors.brandRed;
      stockBadgeText = 'Out of Stock';
    } else if (item.quantity > item.stock) {
      stockBadgeColor = AppColors.brandOrange;
      stockBadgeText = 'Only ${item.stock} left in stock';
    } else if (item.stock <= 5) {
      stockBadgeColor = AppColors.brandOrange;
      stockBadgeText = 'Low Stock (${item.stock} left)';
    }

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.brandRed.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Remove', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      onDismissed: (_) {
        context.read<CartCubit>().removeFromCart(item.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4ECE8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Variant Primary Image (or Product Primary Image)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF4F8F5),
                    border: Border.all(color: const Color(0xFFE4ECE8)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImageView(
                      imageUrl: item.selectedImageUrl,
                      placeholderIcon: Icons.shopping_bag_outlined,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Product Name, Variant Details, Price, SKU
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              context.read<CartCubit>().removeFromCart(item.id);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Selected Variant Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8F5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFD4E2D9)),
                        ),
                        child: Text(
                          item.variantName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      if (item.variantSku.isNotEmpty)
                        Text(
                          'SKU: ${item.variantSku}',
                          style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                        ),
                      const SizedBox(height: 6),

                      // Unit Price
                      Row(
                        children: [
                          Text(
                            '₹${item.unitPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          if (item.quantity > 1) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(₹${item.itemTotal.toStringAsFixed(0)} total)',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Divider(height: 1, color: Color(0xFFEEF3F0)),
            const SizedBox(height: 10),

            // 3. Stock Status Badge, Quantity Controller, Move to Wishlist
            Row(
              children: [
                // Stock Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockBadgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    stockBadgeText,
                    style: TextStyle(
                      color: stockBadgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),

                // Move to Wishlist
                TextButton.icon(
                  onPressed: () {
                    context.read<WishlistBloc>().add(
                          ToggleWishlistEvent(
                            productId: item.productId,
                            productVariantId: item.productVariantId,
                          ),
                        );
                    context.read<CartCubit>().removeFromCart(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Moved item to Wishlist'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite_outline_rounded, size: 15, color: Color(0xFF5A7265)),
                  label: const Text(
                    'Save for later',
                    style: TextStyle(fontSize: 11, color: Color(0xFF5A7265), fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),

                // Quantity +/- Buttons
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4E2D9)),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          context.read<CartCubit>().updateQuantity(
                                cartItemId: item.id,
                                action: 'decrease',
                              );
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Icon(Icons.remove_rounded, size: 16, color: Color(0xFF11261B)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: isMaxQuantity
                            ? null
                            : () {
                                context.read<CartCubit>().updateQuantity(
                                      cartItemId: item.id,
                                      action: 'increase',
                                    );
                              },
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: isMaxQuantity ? Colors.grey : const Color(0xFF11261B),
                          ),
                        ),
                      ),
                    ],
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
