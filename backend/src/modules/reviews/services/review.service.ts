import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { ReviewRepository } from '../repositories/review.repository';
import { CreateReviewDto } from '../dto/create-review.dto';
import { UpdateReviewDto } from '../dto/update-review.dto';
import { VendorReplyDto } from '../dto/vendor-reply.dto';
import { ReviewQueryDto, AdminReviewQueryDto } from '../dto/review-query.dto';

@Injectable()
export class ReviewService {
  constructor(private readonly reviewRepository: ReviewRepository) {}

  /**
   * Customer: Submit a new review
   */
  async createReview(customerId: string, dto: CreateReviewDto) {
    const reviewText = (dto.review || dto.description || '').trim();

    // 1. Validation: Rating must be within 1 to 5
    if (dto.rating < 1 || dto.rating > 5) {
      throw new BadRequestException('Rating must be between 1 and 5');
    }

    // 2. Validation: Empty or short review text (minimum 10 characters)
    if (reviewText.length < 10) {
      throw new BadRequestException('Review text must be at least 10 characters long');
    }

    // 3. Validation: Check if customer has purchased and had product delivered
    const deliveredOrder = await this.reviewRepository.findDeliveredOrderForProduct(
      customerId,
      dto.productId,
      dto.orderId,
    );

    if (!deliveredOrder) {
      throw new BadRequestException(
        'You can only review products from a delivered order that you have purchased.',
      );
    }

    // 4. Validation: Check if active review already exists for this customer and product
    const existingReview = await this.reviewRepository.findByCustomerAndProduct(
      customerId,
      dto.productId,
    );

    if (existingReview) {
      throw new ConflictException(
        'You have already submitted a review for this product. You can update your existing review instead.',
      );
    }

    // 5. Create review inside atomic Prisma Transaction with product rating recalculation
    return this.reviewRepository.createWithTransaction({
      productId: dto.productId,
      productVariantId: dto.variantId || dto.productVariantId,
      customerId,
      orderId: dto.orderId || deliveredOrder.id,
      rating: dto.rating,
      title: dto.title,
      review: reviewText,
      description: reviewText,
      images: dto.images,
    });
  }

  /**
   * Customer: Edit an existing review
   */
  async updateReview(customerId: string, reviewId: string, dto: UpdateReviewDto) {
    const review = await this.reviewRepository.findById(reviewId);

    if (!review) {
      throw new NotFoundException('Review not found');
    }

    if (review.customerId !== customerId) {
      throw new ForbiddenException('You are not authorized to edit this review');
    }

    const reviewText = (dto.review || dto.description || '').trim();
    if ((dto.review !== undefined || dto.description !== undefined) && reviewText.length < 10) {
      throw new BadRequestException('Review text must be at least 10 characters long');
    }

    if (dto.rating !== undefined && (dto.rating < 1 || dto.rating > 5)) {
      throw new BadRequestException('Rating must be between 1 and 5');
    }

    return this.reviewRepository.updateWithTransaction(reviewId, review.productId, {
      rating: dto.rating,
      title: dto.title,
      review: reviewText || undefined,
      description: reviewText || undefined,
      images: dto.images,
    });
  }

  /**
   * Customer: Soft Delete a review
   */
  async deleteReview(customerId: string, reviewId: string) {
    const review = await this.reviewRepository.findById(reviewId);

    if (!review) {
      throw new NotFoundException('Review not found');
    }

    if (review.customerId !== customerId) {
      throw new ForbiddenException('You are not authorized to delete this review');
    }

    await this.reviewRepository.deleteWithTransaction(reviewId, review.productId);

    return { message: 'Review deleted successfully' };
  }

  /**
   * Customer: Get list of own reviews
   */
  async getCustomerReviews(customerId: string, query: ReviewQueryDto) {
    return this.reviewRepository.findByCustomer(customerId, query);
  }

  /**
   * Customer: Get delivered products eligible for review
   */
  async getEligibleProductsForReview(customerId: string) {
    return this.reviewRepository.findEligibleProductsForReview(customerId);
  }

  /**
   * Public: Get reviews & rating summary for a product
   */
  async getProductReviews(productId: string, query: ReviewQueryDto) {
    const summary = await this.reviewRepository.getProductRatingSummary(productId);
    const reviewsData = await this.reviewRepository.findByProduct(productId, query);

    return {
      productId,
      averageRating: summary.averageRating,
      totalReviews: summary.totalReviews,
      ratingDistribution: summary.ratingDistribution,
      fiveStarCount: summary.fiveStarCount,
      fourStarCount: summary.fourStarCount,
      threeStarCount: summary.threeStarCount,
      twoStarCount: summary.twoStarCount,
      oneStarCount: summary.oneStarCount,
      ...reviewsData,
    };
  }

  /**
   * Public: Get rating summary (average, total, 5 to 1 star breakdown)
   */
  async getProductRatingSummary(productId: string) {
    const summary = await this.reviewRepository.getProductRatingSummary(productId);

    return {
      productId,
      averageRating: summary.averageRating,
      totalReviews: summary.totalReviews,
      fiveStarCount: summary.fiveStarCount,
      fourStarCount: summary.fourStarCount,
      threeStarCount: summary.threeStarCount,
      twoStarCount: summary.twoStarCount,
      oneStarCount: summary.oneStarCount,
      ratingDistribution: summary.ratingDistribution,
    };
  }

  /**
   * Vendor: Get reviews on vendor's products
   */
  async getVendorReviews(vendorId: string, query: ReviewQueryDto) {
    return this.reviewRepository.findByVendor(vendorId, query);
  }

  /**
   * Vendor: Reply to a review (Vendor can only reply once)
   */
  async replyToReview(vendorId: string, reviewId: string, dto: VendorReplyDto) {
    const review = await this.reviewRepository.findById(reviewId);

    if (!review) {
      throw new NotFoundException('Review not found');
    }

    if (review.product?.vendorId !== vendorId) {
      throw new ForbiddenException('You can only reply to reviews for your own products');
    }

    // Business rule: Vendor can only reply once
    if (review.vendorReply) {
      throw new ConflictException('You have already replied to this review. Vendor can only reply once.');
    }

    return this.reviewRepository.setVendorReply(reviewId, vendorId, dto.reply);
  }

  /**
   * Vendor: Update a reply
   */
  async updateVendorReply(vendorId: string, replyId: string, dto: VendorReplyDto) {
    const reply = await this.reviewRepository.findReplyById(replyId);

    if (!reply) {
      throw new NotFoundException('Reply not found');
    }

    if (reply.vendorId !== vendorId) {
      throw new ForbiddenException('You can only edit your own replies');
    }

    return this.reviewRepository.updateReply(replyId, dto.reply);
  }

  /**
   * Vendor: Delete a reply
   */
  async deleteVendorReply(vendorId: string, replyId: string) {
    const reply = await this.reviewRepository.findReplyById(replyId);

    if (!reply) {
      throw new NotFoundException('Reply not found');
    }

    if (reply.vendorId !== vendorId) {
      throw new ForbiddenException('You can only delete your own replies');
    }

    await this.reviewRepository.deleteReply(replyId);

    return { message: 'Reply deleted successfully' };
  }

  /**
   * Admin: List all marketplace reviews
   */
  async getAdminReviews(query: AdminReviewQueryDto) {
    return this.reviewRepository.findAll(query);
  }

  /**
   * Admin: Update review moderation status (ACTIVE, HIDDEN)
   */
  async updateReviewStatusByAdmin(reviewId: string, status: 'ACTIVE' | 'HIDDEN') {
    const review = await this.reviewRepository.findById(reviewId);

    if (!review) {
      throw new NotFoundException('Review not found');
    }

    return this.reviewRepository.updateStatusWithTransaction(reviewId, review.productId, status);
  }

  /**
   * Admin: Moderate / Soft Delete an inappropriate review
   */
  async deleteReviewByAdmin(reviewId: string) {
    const review = await this.reviewRepository.findById(reviewId);

    if (!review) {
      throw new NotFoundException('Review not found');
    }

    await this.reviewRepository.deleteWithTransaction(reviewId, review.productId);

    return { message: 'Review removed by administrator' };
  }
}
