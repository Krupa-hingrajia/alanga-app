import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/widgets/status_badge.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onSubmit;
  final VoidCallback? onDelete;
  final VoidCallback? onManageInventory;
  final VoidCallback? onManageShipping;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onEdit,
    this.onSubmit,
    this.onDelete,
    this.onManageInventory,
    this.onManageShipping,
  });

  @override
  Widget build(BuildContext context) {
    final isDraft = product.status.toUpperCase() == 'DRAFT';

    final hasDiscount = product.mrp > product.sellingPrice;
    final discount = hasDiscount
        ? (((product.mrp - product.sellingPrice) / product.mrp) * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A3827).withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5F2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CustomImageView(
                              imageUrl: product.image,
                              placeholderIcon: Icons.shopping_bag_rounded,
                            ),
                          ),
                        ),
                        if (hasDiscount)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6222B),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$discount% off',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              StatusBadge(status: product.status),
                              if (product.stock != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F5F2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: const Color(0xFFE4ECE8),
                                        width: 0.8),
                                  ),
                                  child: Text(
                                    'Stock: ${product.stock}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A3827),
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              _build3DotsMenu(isDraft: isDraft),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.sku.isNotEmpty
                                ? 'SKU: ${product.sku}'
                                : 'SKU: N/A',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7A9A86),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selling Price',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF7A9A86)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${product.sellingPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A8C4E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    if (hasDiscount)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MRP',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF7A9A86)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${product.mrp.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color(0xFFAA7777),
                              color: Color(0xFFAA7777),
                            ),
                          ),
                        ],
                      ),
                    const Spacer(),
                    if (hasDiscount)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE6222B).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Save $discount%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE6222B),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.only(left: 14, right: 14, bottom: 12),
                child: Row(
                  children: [
                    // Manage Inventory Button
                    if (onManageInventory != null) ...[
                      Expanded(
                        child: _ActionBtn(
                          label: 'Inventory',
                          icon: Icons.inventory_2_outlined,
                          color: AppColors.primaryGreen,
                          bgColor: AppColors.primaryGreen.withValues(alpha: 0.09),
                          onTap: onManageInventory!,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Shipping Button
                    if (onManageShipping != null) ...[
                      Expanded(
                        child: _ActionBtn(
                          label: 'Shipping',
                          icon: Icons.local_shipping_outlined,
                          color: const Color(0xFF2563EB),
                          bgColor: const Color(0xFF2563EB).withValues(alpha: 0.09),
                          onTap: onManageShipping!,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    if (onEdit != null) ...[
                      Expanded(
                        child: _ActionBtn(
                          label: 'Edit',
                          icon: Icons.edit_rounded,
                          color: const Color(0xFFF99F1B),
                          bgColor: const Color(0xFFF99F1B).withValues(alpha: 0.09),
                          onTap: onEdit!,
                        ),
                      ),
                      if (onDelete != null || (isDraft && onSubmit != null))
                        const SizedBox(width: 8),
                    ],

                    if (onDelete != null) ...[
                      Expanded(
                        child: _ActionBtn(
                          label: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFE6222B),
                          bgColor: const Color(0xFFE6222B).withValues(alpha: 0.07),
                          onTap: onDelete!,
                        ),
                      ),
                      if (isDraft && onSubmit != null)
                        const SizedBox(width: 8),
                    ],

                    if (isDraft && onSubmit != null)
                      Expanded(
                        child: _ActionBtn(
                          label: 'Submit',
                          icon: Icons.rocket_launch_rounded,
                          color: const Color(0xFF1A8C4E),
                          bgColor: const Color(0xFF1A8C4E).withValues(alpha: 0.09),
                          onTap: onSubmit!,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DotsMenu({required bool isDraft}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F4),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE4ECE8), width: 0.8),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert_rounded,
          size: 18,
          color: Color(0xFF374151),
        ),
        padding: EdgeInsets.zero,
        splashRadius: 18,
        elevation: 6,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        onSelected: (value) {
          if (value == 'inventory') onManageInventory?.call();
          if (value == 'shipping') onManageShipping?.call();
          if (value == 'edit') onEdit?.call();
          if (value == 'delete') onDelete?.call();
          if (value == 'submit') onSubmit?.call();
        },
        itemBuilder: (context) => [
          if (onManageInventory != null)
            const PopupMenuItem(
              value: 'inventory',
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primaryGreen),
                  SizedBox(width: 10),
                  Text(
                    'Manage Inventory',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          if (onManageShipping != null)
            const PopupMenuItem(
              value: 'shipping',
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined, size: 18, color: Color(0xFF2563EB)),
                  SizedBox(width: 10),
                  Text(
                    'Shipping Config',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          if (isDraft && onSubmit != null)
            const PopupMenuItem(
              value: 'submit',
              child: Row(
                children: [
                  Icon(Icons.rocket_launch_rounded, size: 18, color: AppColors.primaryGreen),
                  SizedBox(width: 10),
                  Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          if (onEdit != null)
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: AppColors.brandOrange),
                  SizedBox(width: 10),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          if (onDelete != null)
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.brandRed),
                  SizedBox(width: 10),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandRed,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
