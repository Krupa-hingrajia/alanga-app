import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../data/models/product_variant_model.dart';
import '../../../../core/constants/app_colors.dart';

class ProductVariantCard extends StatefulWidget {
  final ProductVariantModel variant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onManageImages;
  final VoidCallback? onSetDefault;

  const ProductVariantCard({
    super.key,
    required this.variant,
    required this.onEdit,
    required this.onDelete,
    this.onManageImages,
    this.onSetDefault,
  });

  @override
  State<ProductVariantCard> createState() => _ProductVariantCardState();
}

class _ProductVariantCardState extends State<ProductVariantCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.variant;
    final hasStock = v.stock > 0;

    // Filter images that strictly belong to this variant
    final variantImages = v.id.isNotEmpty
        ? v.images.where((img) => img.productVariantId == v.id).toList()
        : v.images;

    String? remoteImg;
    if (variantImages.isNotEmpty) {
      final primary = variantImages.firstWhere((img) => img.isPrimary, orElse: () => variantImages.first);
      remoteImg = primary.imageUrl;
    }
    String? localImg = v.pendingLocalPaths.isNotEmpty ? v.pendingLocalPaths.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? AppColors.primaryGreen : const Color(0xFFE4ECE8),
          width: _isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header Row (Always visible)
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Image Thumbnail or Icon Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4E2D9)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: localImg != null
                            ? Image.file(
                                File(localImg),
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              )
                            : (remoteImg != null && remoteImg.isNotEmpty)
                                ? CustomImageView(
                                    imageUrl: remoteImg,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.style_outlined,
                                    color: Color(0xFF1A3827),
                                    size: 20,
                                  ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Variant Name & SKU
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  v.variantName.isNotEmpty ? v.variantName : 'Unnamed Variant',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF11261B),
                                  ),
                                ),
                              ),
                              if (v.isDefault) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'DEFAULT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'SKU: ${v.sku.isNotEmpty ? v.sku : "N/A"}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontFamily: 'monospace',
                              color: Color(0xFF7A9A86),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price & Expand Icon
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${v.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: hasStock
                                    ? AppColors.primaryGreen.withValues(alpha: 0.1)
                                    : AppColors.brandRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hasStock ? 'Stock: ${v.stock}' : 'Out of stock',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: hasStock ? AppColors.primaryGreen : AppColors.brandRed,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF5A7265),
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expandable Body Details
            if (_isExpanded) ...[
              const Divider(height: 1, color: Color(0xFFE4ECE8)),
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFFAFCFA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Variant Images Preview
                    if (variantImages.isNotEmpty || v.pendingLocalPaths.isNotEmpty) ...[
                      const Text(
                        'Variant Images',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 70,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...v.pendingLocalPaths.map((path) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFD4E2D9)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.file(File(path), fit: BoxFit.cover),
                              ),
                            )),
                            ...variantImages.map((img) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFD4E2D9)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: CustomImageView(imageUrl: img.imageUrl, fit: BoxFit.cover),
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // SKU, Price, Stock Details Card
                    const Text(
                      'Variant Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4ECE8)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('SKU', v.sku.isNotEmpty ? v.sku : 'N/A'),
                          const Divider(height: 12, color: Color(0xFFF0F4F2)),
                          _buildDetailRow('Price', '₹${v.price.toStringAsFixed(2)}'),
                          const Divider(height: 12, color: Color(0xFFF0F4F2)),
                          _buildDetailRow('Stock', '${v.stock} units'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dynamic Attributes Chips
                    if (v.attributes.isNotEmpty) ...[
                      const Text(
                        'Attributes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: v.attributes.entries.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD4E2D9)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${e.key}: ',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5A7265),
                                  ),
                                ),
                                Text(
                                  e.value,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF11261B),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Set Default Option (Switch)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.star_rounded, size: 18, color: AppColors.brandOrange),
                            SizedBox(width: 6),
                            Text(
                              'Default Variant',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: v.isDefault,
                          onChanged: v.isDefault
                              ? null // Cannot toggle off if already default
                              : (val) {
                                  if (val && widget.onSetDefault != null) {
                                    widget.onSetDefault!();
                                  }
                                },
                          activeColor: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons (Manage Images, Edit & Delete)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onManageImages ?? widget.onEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3827),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.photo_library_outlined, size: 16),
                            label: Text(
                              (variantImages.isNotEmpty || v.pendingLocalPaths.isNotEmpty)
                                  ? 'Manage Images (${variantImages.length + v.pendingLocalPaths.length})'
                                  : 'Manage Images',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: widget.onEdit,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.brandOrange),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.brandOrange),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: widget.onDelete,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.brandRed),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.brandRed),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A7265),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
      ],
    );
  }
}
