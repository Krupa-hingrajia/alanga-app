import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../data/models/product_image_model.dart';

class LocalOrRemoteImage {
  final String? id; // Present if uploaded remote image
  final String? localPath; // Present if picked locally
  final String? remoteUrl; // Present if uploaded remote image
  final bool isPrimary;
  final int displayOrder;
  final bool isUploaded;

  LocalOrRemoteImage({
    this.id,
    this.localPath,
    this.remoteUrl,
    required this.isPrimary,
    required this.displayOrder,
    required this.isUploaded,
  });

  LocalOrRemoteImage copyWith({
    String? id,
    String? localPath,
    String? remoteUrl,
    bool? isPrimary,
    int? displayOrder,
    bool? isUploaded,
  }) {
    return LocalOrRemoteImage(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      displayOrder: displayOrder ?? this.displayOrder,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
}

class ProductImagesSection extends StatefulWidget {
  final String? productId; // Null in Add mode, non-null in Edit mode
  final List<ProductImageModel> uploadedImages;
  final List<String> pendingLocalPaths;
  final bool isUploading;
  final double uploadProgress;
  final Function(List<String> newPaths) onAddLocalImages;
  final Function(LocalOrRemoteImage item) onDeleteImage;
  final Function(LocalOrRemoteImage item) onSetPrimary;
  final Function(List<LocalOrRemoteImage> reorderedList) onReorderImages;

  const ProductImagesSection({
    super.key,
    this.productId,
    required this.uploadedImages,
    required this.pendingLocalPaths,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    required this.onAddLocalImages,
    required this.onDeleteImage,
    required this.onSetPrimary,
    required this.onReorderImages,
  });

  @override
  State<ProductImagesSection> createState() => _ProductImagesSectionState();
}

class _ProductImagesSectionState extends State<ProductImagesSection> {
  final ImagePicker _picker = ImagePicker();

  static const List<String> allowedExtensions = [
    '.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif', '.bmp', '.gif'
  ];
  static const int maxFileSizeBytes = 25 * 1024 * 1024; // 25 MB
  static const int maxTotalImages = 10;

  List<LocalOrRemoteImage> _combinedImages = [];

  @override
  void initState() {
    super.initState();
    _buildCombinedList();
  }

  @override
  void didUpdateWidget(covariant ProductImagesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.uploadedImages, widget.uploadedImages) ||
        !listEquals(oldWidget.pendingLocalPaths, widget.pendingLocalPaths) ||
        oldWidget.pendingLocalPaths.length != widget.pendingLocalPaths.length) {
      _buildCombinedList();
    }
  }

  void _buildCombinedList() {
    final list = <LocalOrRemoteImage>[];
    int order = 0;

    // 1. Add uploaded remote images
    for (final img in widget.uploadedImages) {
      list.add(LocalOrRemoteImage(
        id: img.id,
        remoteUrl: img.imageUrl,
        isPrimary: img.isPrimary,
        displayOrder: img.displayOrder,
        isUploaded: true,
      ));
      order = (img.displayOrder >= order) ? img.displayOrder + 1 : order;
    }

    // 2. Add pending local file images
    bool hasPrimary = list.any((img) => img.isPrimary);
    for (int i = 0; i < widget.pendingLocalPaths.length; i++) {
      final path = widget.pendingLocalPaths[i];
      final isPrimary = (!hasPrimary && i == 0);
      list.add(LocalOrRemoteImage(
        localPath: path,
        isPrimary: isPrimary,
        displayOrder: order++,
        isUploaded: false,
      ));
    }

    setState(() {
      _combinedImages = list;
    });
  }

  Future<void> _showImagePickerModal() async {
    final currentTotal = _combinedImages.length;
    if (currentTotal >= maxTotalImages) {
      _showSnackBar('Maximum 10 images allowed.');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4E2D9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(ctx);
                          await Future.delayed(const Duration(milliseconds: 250));
                          if (!mounted) return;
                          _pickFromCamera();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F8F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE4ECE8)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.camera_alt_outlined, color: Color(0xFF1A3827), size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Camera',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF11261B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(ctx);
                          await Future.delayed(const Duration(milliseconds: 250));
                          if (!mounted) return;
                          _pickFromGallery();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F8F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE4ECE8)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.photo_library_outlined, color: Color(0xFF1A3827), size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Gallery',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF11261B),
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
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (photo != null) {
        _validateAndAddFiles([photo]);
      }
    } catch (e) {
      debugPrint('Error picking from camera: $e');
      _showSnackBar('Failed to capture photo from camera.');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> selected = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (selected.isNotEmpty) {
        _validateAndAddFiles(selected);
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      // Fallback for devices where pickMultiImage is unsupported
      try {
        final XFile? single = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
          requestFullMetadata: false,
        );
        if (single != null) {
          _validateAndAddFiles([single]);
        }
      } catch (e2) {
        debugPrint('Fallback error picking from gallery: $e2');
        _showSnackBar('Failed to pick images from gallery.');
      }
    }
  }

  void _validateAndAddFiles(List<XFile> files) {
    final validPaths = <String>[];
    final currentCount = _combinedImages.length;

    for (final file in files) {
      if (currentCount + validPaths.length >= maxTotalImages) {
        _showSnackBar('Maximum 10 images allowed.');
        break;
      }

      String path = file.path;
      if (path.isEmpty) continue;

      if (path.startsWith('file://')) {
        try {
          path = Uri.parse(path).toFilePath();
        } catch (_) {
          path = path.replaceFirst('file://', '');
        }
      }

      final name = file.name.isNotEmpty ? file.name : path;
      final ext = name.contains('.') ? name.substring(name.lastIndexOf('.')).toLowerCase() : '';

      final isAllowed = allowedExtensions.contains(ext) ||
          ext.isEmpty ||
          ext == '.tmp' ||
          (file.mimeType != null && file.mimeType!.startsWith('image/')) ||
          path.contains('image_picker') ||
          path.contains('Camera');

      if (!isAllowed) {
        _showSnackBar('Unsupported file format ($ext).');
        continue;
      }

      final fileObj = File(path);
      if (fileObj.existsSync() && fileObj.lengthSync() > maxFileSizeBytes) {
        _showSnackBar('Image size exceeds 25MB limit.');
        continue;
      }

      validPaths.add(path);
    }

    if (validPaths.isNotEmpty) {
      // Immediately reflect newly picked local images on screen
      setState(() {
        final bool hasPrimary = _combinedImages.any((img) => img.isPrimary);
        for (int i = 0; i < validPaths.length; i++) {
          final p = validPaths[i];
          _combinedImages.add(LocalOrRemoteImage(
            localPath: p,
            isPrimary: !hasPrimary && i == 0,
            displayOrder: _combinedImages.length,
            isUploaded: false,
          ));
        }
      });
      widget.onAddLocalImages(validPaths);
    }
  }

  void _confirmDeleteImage(LocalOrRemoteImage item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Image',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
        ),
        content: const Text(
          'Are you sure you want to delete this image?',
          style: TextStyle(color: Color(0xFF5A7265)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _combinedImages.remove(item);
                if (item.isPrimary && _combinedImages.isNotEmpty) {
                  _combinedImages[0] = _combinedImages[0].copyWith(isPrimary: true);
                }
              });
              widget.onDeleteImage(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _combinedImages.length;

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
          // Header row with step indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, Color(0xFF2E6B48)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'STEP 4',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($totalCount/$maxTotalImages)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: totalCount >= maxTotalImages
                                ? AppColors.brandRed
                                : AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Common Product Images',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Supported JPG, JPEG, PNG, WEBP (Max 5MB each). Drag to reorder.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 16),

          // Upload Progress Bar
          if (widget.isUploading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.uploadProgress > 0 ? widget.uploadProgress : null,
                backgroundColor: const Color(0xFFE4ECE8),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A3827)),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Uploading images...',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1A3827), fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(widget.uploadProgress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1A3827), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Empty state or Horizontal Reorderable Image Cards
          if (totalCount == 0)
            GestureDetector(
              onTap: _showImagePickerModal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4E2D9), style: BorderStyle.solid),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF5A7265)),
                    SizedBox(height: 8),
                    Text(
                      'Tap to upload product images',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A3827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Camera & Gallery supported',
                      style: TextStyle(fontSize: 11, color: Color(0xFF7A9285)),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _combinedImages.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _combinedImages.removeAt(oldIndex);
                    _combinedImages.insert(newIndex, item);
                  });
                  widget.onReorderImages(_combinedImages);
                },
                itemBuilder: (context, index) {
                  final item = _combinedImages[index];
                  return _buildImageCard(item, index, key: ValueKey(item.id ?? item.localPath ?? '$index'));
                },
              ),
            ),
          if (totalCount < maxTotalImages && !widget.isUploading) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showImagePickerModal,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: Text('Add Images ($totalCount/$maxTotalImages)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageCard(LocalOrRemoteImage item, int index, {required Key key}) {
    final bool isPrimary = item.isPrimary;

    return Container(
      key: key,
      margin: const EdgeInsets.only(right: 12),
      width: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimary ? AppColors.primaryGreen : const Color(0xFFE4ECE8),
          width: isPrimary ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 110,
              height: 140,
              child: item.localPath != null
                  ? Image.file(
                      File(item.localPath!),
                      width: 110,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) {
                        return Container(
                          width: 110,
                          height: 140,
                          color: const Color(0xFFF4F8F5),
                          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                        );
                      },
                    )
                  : CustomImageView(
                      imageUrl: item.remoteUrl,
                      width: 110,
                      height: 140,
                      fit: BoxFit.cover,
                      placeholderIcon: Icons.broken_image_outlined,
                    ),
            ),
          ),

          // Gradient overlay for contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Primary Badge or Set Primary Action
          Positioned(
            bottom: 8,
            left: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                if (!isPrimary) {
                  setState(() {
                    for (int i = 0; i < _combinedImages.length; i++) {
                      _combinedImages[i] = _combinedImages[i].copyWith(
                        isPrimary: _combinedImages[i] == item,
                      );
                    }
                  });
                  widget.onSetPrimary(item);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: isPrimary ? const Color(0xFF1A3827) : Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                  border: isPrimary ? Border.all(color: const Color(0xFFFFD700), width: 1) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPrimary ? Icons.star : Icons.star_outline,
                      color: isPrimary ? const Color(0xFFFFD700) : Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        isPrimary ? 'Primary' : 'Make Primary',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                          color: isPrimary ? Colors.white : Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Delete Icon Button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _confirmDeleteImage(item),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
