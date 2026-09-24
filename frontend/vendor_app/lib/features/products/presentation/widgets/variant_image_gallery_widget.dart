import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../data/models/product_image_model.dart';
import '../../data/models/product_variant_model.dart';
import 'product_images_section.dart';

class PrimaryBadge extends StatelessWidget {
  final bool isPrimary;
  const PrimaryBadge({super.key, this.isPrimary = true});

  @override
  Widget build(BuildContext context) {
    if (!isPrimary) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 10, color: Colors.white),
          SizedBox(width: 2),
          Text(
            'PRIMARY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ImageCardWidget extends StatelessWidget {
  final LocalOrRemoteImage item;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const ImageCardWidget({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isPrimary ? AppColors.primaryGreen : const Color(0xFFE4ECE8),
          width: item.isPrimary ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image View
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: item.localPath != null
                ? Image.file(
                    File(item.localPath!),
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  )
                : CustomImageView(
                    imageUrl: item.remoteUrl ?? '',
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
          ),

          // Primary Badge
          if (item.isPrimary)
            const Positioned(
              top: 6,
              left: 6,
              child: PrimaryBadge(),
            ),

          // Action Overlay Menu
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
              ),
            ),
          ),

          // Set Primary Button if not primary
          if (!item.isPrimary)
            Positioned(
              bottom: 6,
              left: 6,
              right: 6,
              child: GestureDetector(
                onTap: onSetPrimary,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'Make Primary',
                      style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VariantImageGalleryWidget extends StatefulWidget {
  final ProductVariantModel variant;
  final List<ProductImageModel> initialImages;
  final Function(List<LocalOrRemoteImage> updatedImages) onSaveGallery;

  const VariantImageGalleryWidget({
    super.key,
    required this.variant,
    required this.initialImages,
    required this.onSaveGallery,
  });

  @override
  State<VariantImageGalleryWidget> createState() => _VariantImageGalleryWidgetState();
}

class _VariantImageGalleryWidgetState extends State<VariantImageGalleryWidget> {
  final ImagePicker _picker = ImagePicker();
  late List<LocalOrRemoteImage> _images;

  static const int maxGalleryImages = 10;
  static const int maxFileSizeBytes = 25 * 1024 * 1024; // 25 MB
  static const List<String> allowedExtensions = [
    '.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif', '.bmp', '.gif'
  ];

  @override
  void initState() {
    super.initState();
    final filtered = widget.variant.id.isNotEmpty
        ? widget.initialImages.where((img) => img.productVariantId == widget.variant.id).toList()
        : widget.initialImages;

    _images = filtered.map((img) {
      return LocalOrRemoteImage(
        id: img.id,
        remoteUrl: img.imageUrl,
        isPrimary: img.isPrimary,
        displayOrder: img.displayOrder,
        isUploaded: true,
      );
    }).toList();

    if (_images.isNotEmpty && !_images.any((img) => img.isPrimary)) {
      _images[0] = _images[0].copyWith(isPrimary: true);
    }
  }

  Future<void> _pickImages(ImageSource source) async {
    if (_images.length >= maxGalleryImages) {
      _showErrorSnackBar('Maximum $maxGalleryImages images allowed per variant gallery.');
      return;
    }

    try {
      final List<XFile> pickedFiles = [];
      if (source == ImageSource.camera) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        if (photo != null) pickedFiles.add(photo);
      } else {
        try {
          final List<XFile> photos = await _picker.pickMultiImage(
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );
          pickedFiles.addAll(photos);
        } catch (_) {
          final XFile? single = await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );
          if (single != null) pickedFiles.add(single);
        }
      }

      if (pickedFiles.isEmpty) return;

      int addedCount = 0;
      for (final file in pickedFiles) {
        if (_images.length >= maxGalleryImages) {
          _showErrorSnackBar('Maximum $maxGalleryImages images limit reached.');
          break;
        }

        final name = file.name.isNotEmpty ? file.name : file.path;
        final ext = name.contains('.') ? name.substring(name.lastIndexOf('.')).toLowerCase() : '';
        final isAllowed = allowedExtensions.contains(ext) ||
            ext.isEmpty ||
            ext == '.tmp' ||
            (file.mimeType != null && file.mimeType!.startsWith('image/')) ||
            file.path.contains('image_picker') ||
            file.path.contains('Camera');

        if (!isAllowed) {
          _showErrorSnackBar('Invalid file format: ${file.name}.');
          continue;
        }

        final fileLength = await file.length();
        if (fileLength > maxFileSizeBytes) {
          _showErrorSnackBar('File size too large: ${file.name}. Maximum 25MB allowed.');
          continue;
        }

        final isFirst = _images.isEmpty;
        _images.add(LocalOrRemoteImage(
          localPath: file.path,
          isPrimary: isFirst,
          displayOrder: _images.length,
          isUploaded: false,
        ));
        addedCount++;
      }

      if (addedCount > 0) {
        setState(() {});
        widget.onSaveGallery(_images);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.brandRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setPrimary(int index) {
    setState(() {
      for (int i = 0; i < _images.length; i++) {
        _images[i] = _images[i].copyWith(isPrimary: i == index);
      }
    });
    widget.onSaveGallery(_images);
  }

  void _deleteImage(int index) {
    setState(() {
      final wasPrimary = _images[index].isPrimary;
      _images.removeAt(index);
      if (wasPrimary && _images.isNotEmpty) {
        _images[0] = _images[0].copyWith(isPrimary: true);
      }
    });
    widget.onSaveGallery(_images);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD4E2D9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            children: [
              const Icon(Icons.collections_outlined, color: AppColors.primaryGreen, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.variant.variantName} Images',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_images.length}/$maxGalleryImages Images • Max 5MB each',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF7A9A86)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal Image List & Add Buttons
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  // Add Image Tile
                  if (_images.length >= maxGalleryImages) return const SizedBox.shrink();
                  return Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBDCD1), style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryGreen, size: 22),
                              onPressed: () => _pickImages(ImageSource.camera),
                              tooltip: 'Camera',
                            ),
                            IconButton(
                              icon: const Icon(Icons.photo_library_outlined, color: AppColors.primaryGreen, size: 22),
                              onPressed: () => _pickImages(ImageSource.gallery),
                              tooltip: 'Gallery',
                            ),
                          ],
                        ),
                        const Text(
                          'Add Image',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1A3827)),
                        ),
                      ],
                    ),
                  );
                }

                final item = _images[index];
                return ImageCardWidget(
                  item: item,
                  onDelete: () => _deleteImage(index),
                  onSetPrimary: () => _setPrimary(index),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Save / Close Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
