import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/localization/app_localizations.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EFEA), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3827).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomImageView(
                              imageUrl: product.primaryImageUrl ?? product.image,
                              placeholderIcon: Icons.shopping_bag_rounded,
                            ),
                          ),
                        ),
                        if (hasDiscount)
                          Positioned(
                            top: 3,
                            left: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6222B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$discount%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              StatusBadge(status: product.status),
                              if (product.stock != null) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F5F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE4ECE8),
                                        width: 0.8),
                                  ),
                                  child: Text(
                                    '${context.tr('stock')}: ${product.stock}',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A3827),
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              _build3DotsMenu(context, isDraft: isDraft),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF11261B),
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.sku.isNotEmpty
                                ? 'SKU: ${product.sku}'
                                : 'SKU: N/A',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF7A9A86),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('selling_price'),
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF7A9A86)),
                        ),
                        Text(
                          '₹${product.sellingPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A8C4E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    if (hasDiscount)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('mrp'),
                            style: const TextStyle(
                                fontSize: 9, color: Color(0xFF7A9A86)),
                          ),
                          Text(
                            '₹${product.mrp.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12.5,
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
                            horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE6222B).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${context.tr('save')} $discount%',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE6222B),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.only(left: 10, right: 10, bottom: 8),
                child: Row(
                  children: [
                    // Manage Inventory Button
                    if (onManageInventory != null) ...[
                      Expanded(
                        child: _ActionBtn(
                          label: context.tr('inventory'),
                          icon: Icons.inventory_2_outlined,
                          color: AppColors.primaryGreen,
                          bgColor: AppColors.primaryGreen.withValues(alpha: 0.09),
                          onTap: onManageInventory!,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],

                    // Shipping Button
                    if (onManageShipping != null) ...[
                      Expanded(
                        child: _ActionBtn(
                          label: context.tr('shipping'),
                          icon: Icons.local_shipping_outlined,
                          color: const Color(0xFF2563EB),
                          bgColor: const Color(0xFF2563EB).withValues(alpha: 0.09),
                          onTap: onManageShipping!,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],

                    if (onEdit != null) ...[
                      Expanded(
                        child: _ActionBtn(
                          label: context.tr('edit'),
                          icon: Icons.edit_rounded,
                          color: const Color(0xFFF99F1B),
                          bgColor: const Color(0xFFF99F1B).withValues(alpha: 0.09),
                          onTap: onEdit!,
                        ),
                      ),
                      if (onDelete != null || (isDraft && onSubmit != null))
                        const SizedBox(width: 5),
                    ],

                    if (onDelete != null) ...[
                      Expanded(
                        child: _ActionBtn(
                          label: context.tr('delete'),
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFE6222B),
                          bgColor: const Color(0xFFE6222B).withValues(alpha: 0.07),
                          onTap: onDelete!,
                        ),
                      ),
                      if (isDraft && onSubmit != null)
                        const SizedBox(width: 5),
                    ],

                    if (isDraft && onSubmit != null)
                      Expanded(
                        child: _ActionBtn(
                          label: context.tr('submit'),
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

  Widget _build3DotsMenu(BuildContext context, {required bool isDraft}) {
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
            PopupMenuItem(
              value: 'inventory',
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('manage_inventory'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          if (onManageShipping != null)
            PopupMenuItem(
              value: 'shipping',
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('shipping_config'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          if (isDraft && onSubmit != null)
            PopupMenuItem(
              value: 'submit',
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch_rounded, size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('submit'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          if (onEdit != null)
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 18, color: AppColors.brandOrange),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('edit'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          if (onDelete != null)
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.brandRed),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('delete'),
                    style: const TextStyle(
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
