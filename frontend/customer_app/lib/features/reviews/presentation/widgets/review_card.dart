import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/review_model.dart';
import 'star_rating_widget.dart';
import 'image_lightbox_dialog.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildThumbnail(BuildContext context, String url, int index, List<String> allImages) {
    Widget imageWidget;
    if (url.startsWith('data:image')) {
      try {
        final commaIndex = url.indexOf(',');
        final base64String = commaIndex != -1 ? url.substring(commaIndex + 1) : url;
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: 64,
          height: 64,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 24, color: Colors.grey),
        );
      } catch (_) {
        imageWidget = const Icon(Icons.broken_image, size: 24, color: Colors.grey);
      }
    } else {
      imageWidget = Image.network(
        url,
        fit: BoxFit.cover,
        width: 64,
        height: 64,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 24, color: Colors.grey),
      );
    }

    return GestureDetector(
      onTap: () => ImageLightboxDialog.show(context, allImages, initialIndex: index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarLetter = review.customerName.isNotEmpty
        ? review.customerName.substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Customer Avatar, Name, Rating, and Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                backgroundImage: review.customerAvatar != null && review.customerAvatar!.isNotEmpty
                    ? NetworkImage(review.customerAvatar!)
                    : null,
                child: review.customerAvatar == null || review.customerAvatar!.isEmpty
                    ? Text(
                        avatarLetter,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),

              // Name and Verified Purchase Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.customerName,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.isVerifiedPurchase) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEF7EC),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, size: 10, color: Color(0xFF03543F)),
                                SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF03543F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF7A9A86)),
                    ),
                  ],
                ),
              ),

              // Star rating
              StarRatingWidget(
                rating: review.rating,
                size: 16,
              ),
            ],
          ),

          // Variant badge if available
          if (review.variantName != null &&
              review.variantName!.isNotEmpty &&
              review.variantName != 'Default Variant') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Variant: ${review.variantName}',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4C6656),
                ),
              ),
            ),
          ],

          // Title (if provided)
          if (review.title != null && review.title!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11261B),
              ),
            ),
          ],

          // Description
          const SizedBox(height: 6),
          Text(
            review.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              height: 1.4,
            ),
          ),

          // Review Images Gallery
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                itemBuilder: (ctx, idx) =>
                    _buildThumbnail(ctx, review.images[idx], idx, review.images),
              ),
            ),
          ],

          // Vendor Replies
          if (review.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...review.replies.map((rep) {
              return Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2EBE6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, size: 14, color: AppColors.primaryGreen),
                        const SizedBox(width: 5),
                        Text(
                          '${rep.vendorName} (Seller Response)',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(rep.createdAt),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rep.reply,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.3),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Edit / Delete Actions (if owner)
          if (isOwner && (onEdit != null || onDelete != null)) ...[
            const Divider(height: 20, color: Color(0xFFEEF3F0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.brandRed),
                    label: const Text(
                      'Delete',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandRed),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (onEdit != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryGreen),
                    label: const Text(
                      'Edit Review',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryGreen),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
