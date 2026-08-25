import 'package:flutter/material.dart';
import '../../data/models/product_variant_model.dart';
import '../../data/models/product_image_model.dart';
import '../../data/models/attribute_model.dart';
import '../../../../core/constants/app_colors.dart';
import 'product_variant_card.dart';
import 'add_edit_variant_bottom_sheet.dart';
import 'variant_image_gallery_widget.dart';

class ProductVariantsSection extends StatelessWidget {
  final String? productId;
  final List<ProductVariantModel> variants;
  final List<AttributeModel> availableAttributes;
  final Function(ProductVariantModel newVariant) onAddVariant;
  final Function(ProductVariantModel updatedVariant) onUpdateVariant;
  final Function(ProductVariantModel variantToDelete) onDeleteVariant;
  final Function(ProductVariantModel variant)? onManageVariantImages;

  const ProductVariantsSection({
    super.key,
    this.productId,
    required this.variants,
    required this.availableAttributes,
    required this.onAddVariant,
    required this.onUpdateVariant,
    required this.onDeleteVariant,
    this.onManageVariantImages,
  });

  void _openAddVariantSheet(BuildContext context) {
    final existingSkus = variants.map((v) => v.sku.toUpperCase()).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditVariantBottomSheet(
        availableAttributes: availableAttributes,
        existingSkus: existingSkus,
        onSave: onAddVariant,
      ),
    );
  }

  void _openEditVariantSheet(BuildContext context, ProductVariantModel variant) {
    final existingSkus = variants
        .where((v) => v.id != variant.id)
        .map((v) => v.sku.toUpperCase())
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditVariantBottomSheet(
        initialVariant: variant,
        availableAttributes: availableAttributes,
        existingSkus: existingSkus,
        onSave: onUpdateVariant,
      ),
    );
  }

  void _openManageVariantImagesSheet(BuildContext context, ProductVariantModel variant) {
    final filteredImages = variant.id.isNotEmpty
        ? variant.images.where((img) => img.productVariantId == variant.id).toList()
        : variant.images.where((img) => img.productVariantId == null || img.productVariantId == variant.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VariantImageGalleryWidget(
        variant: variant,
        initialImages: filteredImages,
        onSaveGallery: (updatedImages) {
          final remoteList = <ProductImageModel>[];
          final localPaths = <String>[];

          for (final img in updatedImages) {
            if (img.localPath != null && img.localPath!.isNotEmpty) {
              localPaths.add(img.localPath!);
            } else if (img.remoteUrl != null && img.remoteUrl!.isNotEmpty) {
              remoteList.add(ProductImageModel(
                id: img.id ?? '',
                productId: variant.productId,
                productVariantId: variant.id,
                imageUrl: img.remoteUrl!,
                isPrimary: img.isPrimary,
                displayOrder: img.displayOrder,
              ));
            }
          }

          final updated = variant.copyWith(
            images: remoteList,
            pendingLocalPaths: localPaths,
          );

          onUpdateVariant(updated);
          if (onManageVariantImages != null) {
            onManageVariantImages!(updated);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductVariantModel variant) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Variant',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
        ),
        content: Text(
          'Are you sure you want to delete the variant "${variant.variantName}"? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFF4C6656), fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              onDeleteVariant(variant);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Product Variants',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${variants.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _openAddVariantSheet(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4E2D9)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: Color(0xFF1A3827)),
                      SizedBox(width: 4),
                      Text(
                        'Add Variant',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3827),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Variants List or Empty State Placeholder
          if (variants.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE4ECE8), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  const Icon(Icons.style_outlined, size: 36, color: Color(0xFF7A9A86)),
                  const SizedBox(height: 8),
                  const Text(
                    'No Variants Added Yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap "+ Add Variant" to specify custom colors, sizes, storage, or materials.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF5A7265)),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: variants.length,
              itemBuilder: (ctx, i) {
                final v = variants[i];
                return ProductVariantCard(
                  variant: v,
                  onEdit: () => _openEditVariantSheet(context, v),
                  onDelete: () => _confirmDelete(context, v),
                  onManageImages: () => _openManageVariantImagesSheet(context, v),
                );
              },
            ),
        ],
      ),
    );
  }
}
