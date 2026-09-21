import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../data/models/review_model.dart';
import '../bloc/customer_reviews_cubit.dart';
import '../bloc/customer_reviews_state.dart';
import '../widgets/star_rating_widget.dart';

class WriteReviewScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String? productImage;
  final String orderId;
  final String? variantId;
  final String? variantName;
  final ReviewModel? existingReview;

  const WriteReviewScreen({
    super.key,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.orderId,
    this.variantId,
    this.variantName,
    this.existingReview,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late int _rating;
  late List<String> _images;
  bool _isPickingImage = false;

  bool get isEditMode => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 5;
    _titleController = TextEditingController(text: widget.existingReview?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existingReview?.description ?? '');
    _images = List<String>.from(widget.existingReview?.images ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can upload up to 5 photos per review.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      setState(() => _isPickingImage = true);
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUri = 'data:image/jpeg;base64,$base64String';

        setState(() {
          _images.add(dataUri);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.brandRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Review Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen),
                ),
                title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryGreen),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<CustomerReviewsCubit>();
    bool success = false;

    if (isEditMode) {
      success = await cubit.updateReview(
        reviewId: widget.existingReview!.id,
        productId: widget.productId,
        rating: _rating,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: _images,
      );
    } else {
      success = await cubit.createReview(
        productId: widget.productId,
        orderId: widget.orderId,
        variantId: widget.variantId,
        rating: _rating,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        images: _images,
      );
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode ? 'Review updated successfully.' : 'Thank you for your review.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.brandRed, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('Delete Review?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete this review? This action cannot be undone.',
          style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final cubit = context.read<CustomerReviewsCubit>();
              final success = await cubit.deleteReview(
                reviewId: widget.existingReview!.id,
                productId: widget.productId,
              );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Review deleted successfully.'),
                    backgroundColor: AppColors.darkGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                Navigator.of(context).pop(true);
              }
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

  Widget _buildImageThumbnail(String url, int index) {
    Widget imageWidget;
    if (url.startsWith('data:image')) {
      try {
        final commaIndex = url.indexOf(',');
        final base64String = commaIndex != -1 ? url.substring(commaIndex + 1) : url;
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        imageWidget = const Icon(Icons.broken_image, color: Colors.grey);
      }
    } else {
      imageWidget = Image.network(url, fit: BoxFit.cover);
    }

    return Stack(
      children: [
        Container(
          width: 72,
          height: 72,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2EBE6)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: imageWidget,
          ),
        ),
        Positioned(
          top: 2,
          right: 12,
          child: GestureDetector(
            onTap: () => setState(() => _images.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF11261B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditMode ? 'Edit Review' : 'Write Review',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.brandRed),
              tooltip: 'Delete Review',
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: BlocConsumer<CustomerReviewsCubit, CustomerReviewsState>(
        listener: (context, state) {
          if (state.status == CustomerReviewsStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.brandRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == CustomerReviewsStatus.submitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. PRODUCT PREVIEW CARD
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2EBE6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAF8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE6EFEA)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomImageView(
                              imageUrl: widget.productImage ?? '',
                              fit: BoxFit.cover,
                              placeholderIcon: Icons.shopping_bag_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.productName,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.variantName != null &&
                                  widget.variantName!.isNotEmpty &&
                                  widget.variantName != 'Default Variant') ...[
                                const SizedBox(height: 3),
                                Text(
                                  'Variant: ${widget.variantName}',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF5A7265)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. RATING SELECTOR CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2EBE6)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'How was your overall experience?',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        StarRatingWidget(
                          rating: _rating,
                          size: 38,
                          showLabel: true,
                          onRatingChanged: (newRating) {
                            setState(() => _rating = newRating);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. TITLE & DESCRIPTION CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2EBE6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Review Title Field
                        const Text(
                          'Review Title (Optional)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _titleController,
                          maxLength: 100,
                          decoration: InputDecoration(
                            hintText: 'e.g. Excellent fit and top quality!',
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF9FBFA),
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2EBE6)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2EBE6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Review Description Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Detailed Review',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                              ),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _descriptionController,
                              builder: (context, value, _) {
                                final len = value.text.trim().length;
                                final isValid = len >= 10 && len <= 1000;
                                return Text(
                                  '$len / 1000',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: len < 10
                                        ? const Color(0xFFEF4444)
                                        : (isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          maxLength: 1000,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Please enter your review description';
                            }
                            if (text.length < 10) {
                              return 'Review must be at least 10 characters long';
                            }
                            if (text.length > 1000) {
                              return 'Review cannot exceed 1000 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'What did you love or dislike about this product? How is the material, sizing, and comfort?',
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                            filled: true,
                            fillColor: const Color(0xFFF9FBFA),
                            counterText: '',
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2EBE6)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2EBE6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Minimum 10 characters required',
                          style: TextStyle(fontSize: 11, color: Color(0xFF7A9A86)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. IMAGE ATTACHMENT CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2EBE6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add Photos (Optional)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                              ),
                            ),
                            Text(
                              '${_images.length} / 5',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Upload button
                              if (_images.length < 5)
                                GestureDetector(
                                  onTap: _isPickingImage ? null : _showImagePickerSheet,
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FBFA),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: _isPickingImage
                                        ? const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primaryGreen,
                                              ),
                                            ),
                                          )
                                        : const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_a_photo_outlined, color: AppColors.primaryGreen, size: 22),
                                              SizedBox(height: 4),
                                              Text('Add Photo', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                            ],
                                          ),
                                  ),
                                ),

                              // Thumbnails
                              ..._images.asMap().entries.map((e) => _buildImageThumbnail(e.value, e.key)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primaryGreen.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                            )
                          : Text(
                              isEditMode ? 'Update Review' : 'Submit Review',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
