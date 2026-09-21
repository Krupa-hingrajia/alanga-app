import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../data/models/review_model.dart';
import '../bloc/customer_reviews_cubit.dart';
import '../bloc/customer_reviews_state.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/image_lightbox_dialog.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerReviewsCubit>().loadCustomerReviews();
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _handleEditReview(ReviewModel review) async {
    final result = await context.push('/reviews/write', extra: {
      'productId': review.productId,
      'productName': review.productName ?? 'Product',
      'productImage': review.productImage,
      'orderId': review.orderId,
      'variantId': review.productVariantId,
      'variantName': review.variantName,
      'existingReview': review,
    });

    if (result == true && mounted) {
      context.read<CustomerReviewsCubit>().loadCustomerReviews();
    }
  }

  void _handleDeleteReview(ReviewModel review) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Review?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete your review? This action cannot be undone.',
          style: TextStyle(fontSize: 13.5, color: Color(0xFF4C6656), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await context.read<CustomerReviewsCubit>().deleteReview(
                    reviewId: review.id,
                    productId: review.productId,
                  );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review deleted successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // 1. PRODUCT HEADER
          InkWell(
            onTap: () => context.push('/products/${review.productId}'),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE6EFEA)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImageView(
                        imageUrl: review.productImage ?? '',
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
                          review.productName ?? 'Product',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (review.variantName != null && review.variantName!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Variant: ${review.variantName}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF5A7265)),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          'Reviewed on ${_formatDate(review.createdAt)}',
                          style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEF3F0)),

          // 2. REVIEW CONTENT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Star Rating
                Row(
                  children: [
                    StarRatingWidget(rating: review.rating, size: 15),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEF7EC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF03543F)),
                          SizedBox(width: 3),
                          Text(
                            'Verified Purchase',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF03543F)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                if (review.title != null && review.title!.isNotEmpty) ...[
                  Text(
                    review.title!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Description
                Text(
                  review.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),

                // Attached Images
                if (review.images.isNotEmpty) ...[
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.images.length,
                      itemBuilder: (context, idx) {
                        final imgUrl = review.images[idx];
                        return GestureDetector(
                          onTap: () => ImageLightboxDialog.show(context, review.images, initialIndex: idx),
                          child: Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CustomImageView(
                                imageUrl: imgUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. VENDOR REPLY (if available)
                if (review.vendorReply != null && review.vendorReply!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2FBF6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD1EBE0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.storefront_rounded, size: 14, color: AppColors.primaryGreen),
                            SizedBox(width: 6),
                            Text(
                              'Seller Response',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          review.vendorReply!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1E3A2F), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 4. ACTION BUTTONS (EDIT / DELETE)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _handleDeleteReview(review),
                      icon: const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.brandRed),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandRed),
                      ),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton.icon(
                      onPressed: () => _handleEditReview(review),
                      icon: const Icon(Icons.edit_outlined, size: 15, color: AppColors.primaryGreen),
                      label: const Text(
                        'Edit Review',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Reviews & Ratings',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
        ),
      ),
      body: BlocBuilder<CustomerReviewsCubit, CustomerReviewsState>(
        builder: (context, state) {
          if (state.status == CustomerReviewsStatus.loading && state.reviews.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (state.reviews.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () => context.read<CustomerReviewsCubit>().loadCustomerReviews(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2EBE6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.rate_review_outlined, size: 40, color: Color(0xFF9CA3AF)),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Reviews Yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You have not reviewed any products yet.\nDelivered items from your orders can be reviewed here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF7A9A86), height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/orders'),
                          icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                          label: const Text('View Delivered Orders', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () => context.read<CustomerReviewsCubit>().loadCustomerReviews(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reviews.length,
              itemBuilder: (context, index) => _buildReviewItem(state.reviews[index]),
            ),
          );
        },
      ),
    );
  }
}
