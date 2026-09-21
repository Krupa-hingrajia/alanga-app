import { ReviewQueryDto, AdminReviewQueryDto } from '../dto/review-query.dto';

export interface RatingSummary {
  averageRating: number;
  totalReviews: number;
  ratingDistribution: Record<number, number>;
  fiveStarCount: number;
  fourStarCount: number;
  threeStarCount: number;
  twoStarCount: number;
  oneStarCount: number;
}

export interface PaginatedReviews<T = any> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface CreateReviewData {
  productId: string;
  productVariantId?: string;
  customerId: string;
  orderId: string;
  rating: number;
  title?: string;
  review: string;
  description?: string;
  images?: string[];
}

export interface UpdateReviewData {
  rating?: number;
  title?: string;
  review?: string;
  description?: string;
  images?: string[];
  deletedAt?: Date | null;
  status?: string;
}

export interface IReviewRepository {
  createWithTransaction(data: CreateReviewData): Promise<any>;

  findById(id: string): Promise<any>;

  findByCustomerAndProduct(customerId: string, productId: string, includeDeleted?: boolean): Promise<any>;

  updateWithTransaction(id: string, productId: string, data: UpdateReviewData): Promise<any>;

  deleteWithTransaction(id: string, productId: string): Promise<any>;

  updateStatusWithTransaction(id: string, productId: string, status: string): Promise<any>;

  findByProduct(productId: string, query: ReviewQueryDto): Promise<PaginatedReviews>;

  getProductRatingSummary(productId: string): Promise<RatingSummary>;

  findByCustomer(customerId: string, query: ReviewQueryDto): Promise<PaginatedReviews>;

  findByVendor(vendorId: string, query: ReviewQueryDto): Promise<PaginatedReviews>;

  findAll(query: AdminReviewQueryDto): Promise<PaginatedReviews>;

  setVendorReply(reviewId: string, vendorId: string, reply: string): Promise<any>;

  findReplyById(id: string): Promise<any>;

  updateReply(id: string, reply: string): Promise<any>;

  deleteReply(id: string): Promise<any>;

  findDeliveredOrderForProduct(customerId: string, productId: string, orderId?: string): Promise<any>;

  findEligibleProductsForReview(customerId: string): Promise<any[]>;
}
