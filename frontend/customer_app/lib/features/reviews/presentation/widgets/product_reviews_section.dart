import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../domain/repositories/review_repository.dart';
import '../bloc/review_cubit.dart';
import '../bloc/review_state.dart';
import '../bloc/customer_reviews_cubit.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/review_card.dart';

class ProductReviewsSection extends StatefulWidget {
  final String productId;
  final String? productName;
  final String? productImage;
  final VoidCallback? onReviewSubmitted;

  const ProductReviewsSection({
    super.key,
    required this.productId,
    this.productName,
    this.productImage,
    this.onReviewSubmitted,
  });

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  late final ReviewCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ReviewCubit(repository: sl<ReviewRepository>());
    _cubit.loadProductReviews(widget.productId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Widget _buildRatingDistributionBar(int star, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$star',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                ),
                const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(
                  star >= 4
                      ? const Color(0xFF10B981)
                      : (star == 3 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToWriteReview(dynamic existingReview, dynamic eligibleItem) async {
    final result = await context.push('/reviews/write', extra: {
      'productId': widget.productId,
      'productName': widget.productName ?? 'Product',
      'productImage': widget.productImage,
      'orderId': existingReview?.orderId ?? eligibleItem?['orderId'] ?? '',
      'variantId': existingReview?.productVariantId ?? eligibleItem?['variantId'],
      'variantName': existingReview?.variantName ?? eligibleItem?['variantName'],
      'existingReview': existingReview,
    });

    if (result == true && mounted) {
      _cubit.loadProductReviews(widget.productId, refresh: true);
      context.read<CustomerReviewsCubit>().loadCustomerReviews();
      widget.onReviewSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (context, state) {
          final isLoading = state.status == ReviewStatus.loading && state.productReviews.isEmpty;
          final summary = state.ratingSummary;

          final avgRating = summary?.averageRating ?? 0.0;
          final totalReviews = summary?.totalReviews ?? 0;
          final dist = summary?.ratingDistribution ?? {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
          final reviewsList = state.productReviews;

          // Check if current logged-in customer has already reviewed this product
          final customerReviewsState = context.watch<CustomerReviewsCubit>().state;
          final existingReview = customerReviewsState.getReviewForProduct(widget.productId);
          final hasReviewed = existingReview != null;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Customer Reviews Title & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.rate_review_outlined, color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Customer Reviews',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        if (totalReviews > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '($totalReviews)',
                            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    if (hasReviewed)
                      TextButton.icon(
                        onPressed: () => _navigateToWriteReview(existingReview, null),
                        icon: const Icon(Icons.edit_rounded, size: 14, color: Color(0xFFD97706)),
                        label: const Text(
                          'Edit Review',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFEEF3F0)),

                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  )
                else if (totalReviews == 0) ...[
                  // EMPTY STATE
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAF8),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2EBE6)),
                            ),
                            child: const Icon(
                              Icons.star_border_rounded,
                              size: 38,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Reviews Yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Be the first customer to review this product.',
                            style: TextStyle(fontSize: 12.5, color: Color(0xFF7A9A86)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // 2. RATING SUMMARY WITH PROGRESS BARS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FBFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE6EFEA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Big Rating Number & Stars
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StarRatingWidget(
                              rating: avgRating.round(),
                              size: 16,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Based on $totalReviews reviews',
                              style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Container(width: 1, height: 90, color: const Color(0xFFE2EBE6)),
                        const SizedBox(width: 16),

                        // Right: 5 star to 1 star breakdown
                        Expanded(
                          child: Column(
                            children: [
                              _buildRatingDistributionBar(5, summary?.fiveStarCount ?? dist[5] ?? 0, totalReviews),
                              _buildRatingDistributionBar(4, summary?.fourStarCount ?? dist[4] ?? 0, totalReviews),
                              _buildRatingDistributionBar(3, summary?.threeStarCount ?? dist[3] ?? 0, totalReviews),
                              _buildRatingDistributionBar(2, summary?.twoStarCount ?? dist[2] ?? 0, totalReviews),
                              _buildRatingDistributionBar(1, summary?.oneStarCount ?? dist[1] ?? 0, totalReviews),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. SORTING & RATING FILTER BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating filter pill
                      DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: state.selectedRating,
                          isDense: true,
                          hint: const Text(
                            'All Ratings',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primaryGreen),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Ratings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                            ...[5, 4, 3, 2, 1].map((r) => DropdownMenuItem<int?>(
                                  value: r,
                                  child: Text('$r Stars only', style: const TextStyle(fontSize: 12)),
                                )),
                          ],
                          onChanged: (r) => _cubit.filterByRating(widget.productId, r),
                        ),
                      ),

                      // Sort dropdown: Newest, Oldest, Highest Rating, Lowest Rating
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.sortBy,
                          isDense: true,
                          icon: const Icon(Icons.sort_rounded, size: 18, color: Color(0xFF11261B)),
                          items: const [
                            DropdownMenuItem(
                              value: 'newest',
                              child: Text('Newest', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                            DropdownMenuItem(
                              value: 'oldest',
                              child: Text('Oldest', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                            DropdownMenuItem(
                              value: 'highest_rating',
                              child: Text('Highest Rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                            DropdownMenuItem(
                              value: 'lowest_rating',
                              child: Text('Lowest Rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                          onChanged: (sort) {
                            if (sort != null) {
                              _cubit.changeSortBy(widget.productId, sort);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. REVIEWS LIST
                  if (reviewsList.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No reviews match the selected filter.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviewsList.length,
                      itemBuilder: (context, index) {
                        final review = reviewsList[index];
                        final isOwner = review.id == existingReview?.id;
                        return ReviewCard(
                          review: review,
                          isOwner: isOwner,
                          onEdit: isOwner ? () => _navigateToWriteReview(review, null) : null,
                          onDelete: isOwner
                              ? () async {
                                  final deleted = await context.read<CustomerReviewsCubit>().deleteReview(
                                        reviewId: review.id,
                                        productId: widget.productId,
                                      );
                                  if (deleted && mounted) {
                                    _cubit.loadProductReviews(widget.productId, refresh: true);
                                    widget.onReviewSubmitted?.call();
                                  }
                                }
                              : null,
                        );
                      },
                    ),

                    // 5. LAZY LOADING / INFINITE SCROLL BUTTON OR INDICATOR
                    if (state.hasMore) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: state.isLoadingMore ? null : () => _cubit.loadMoreReviews(widget.productId),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCFDDD5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: state.isLoadingMore
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                                )
                              : const Text(
                                  'Load More Reviews',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                ),
                        ),
                      ),
                    ],
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
