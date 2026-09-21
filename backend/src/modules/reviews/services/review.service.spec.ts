import { Test, TestingModule } from '@nestjs/testing';
import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { ReviewService } from './review.service';
import { ReviewRepository } from '../repositories/review.repository';

describe('ReviewService', () => {
  let service: ReviewService;
  let repository: jest.Mocked<ReviewRepository>;

  const mockReviewRepository = () => ({
    createWithTransaction: jest.fn(),
    findById: jest.fn(),
    findByCustomerAndProduct: jest.fn(),
    updateWithTransaction: jest.fn(),
    deleteWithTransaction: jest.fn(),
    updateStatusWithTransaction: jest.fn(),
    findByProduct: jest.fn(),
    getProductRatingSummary: jest.fn(),
    findByCustomer: jest.fn(),
    findByVendor: jest.fn(),
    findAll: jest.fn(),
    setVendorReply: jest.fn(),
    findReplyById: jest.fn(),
    updateReply: jest.fn(),
    deleteReply: jest.fn(),
    findDeliveredOrderForProduct: jest.fn(),
    findEligibleProductsForReview: jest.fn(),
  });

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReviewService,
        {
          provide: ReviewRepository,
          useFactory: mockReviewRepository,
        },
      ],
    }).compile();

    service = module.get<ReviewService>(ReviewService);
    repository = module.get(ReviewRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createReview', () => {
    const customerId = 'cust-123';
    const createDto = {
      productId: 'prod-123',
      orderId: 'order-123',
      rating: 5,
      title: 'Amazing Product',
      review: 'Truly superior craftsmanship and perfect fit on delivery.',
      images: ['https://example.com/photo1.jpg'],
    };

    it('should throw BadRequestException if rating is outside 1-5', async () => {
      await expect(
        service.createReview(customerId, { ...createDto, rating: 6 }),
      ).rejects.toThrow(BadRequestException);

      await expect(
        service.createReview(customerId, { ...createDto, rating: 0 }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if review text is shorter than 10 characters', async () => {
      await expect(
        service.createReview(customerId, { ...createDto, review: 'Short' }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if order is not delivered or purchased', async () => {
      repository.findDeliveredOrderForProduct.mockResolvedValue(null);

      await expect(service.createReview(customerId, createDto)).rejects.toThrow(
        BadRequestException,
      );
      expect(repository.findDeliveredOrderForProduct).toHaveBeenCalledWith(
        customerId,
        createDto.productId,
        createDto.orderId,
      );
    });

    it('should throw ConflictException if duplicate review already exists for this customer and product', async () => {
      repository.findDeliveredOrderForProduct.mockResolvedValue({ id: 'order-123' } as any);
      repository.findByCustomerAndProduct.mockResolvedValue({ id: 'rev-existing' } as any);

      await expect(service.createReview(customerId, createDto)).rejects.toThrow(
        ConflictException,
      );
      expect(repository.findByCustomerAndProduct).toHaveBeenCalledWith(
        customerId,
        createDto.productId,
      );
    });

    it('should create review inside atomic transaction and recalculate product rating', async () => {
      const deliveredOrder = { id: 'order-123', customerId, status: 'DELIVERED' };
      const createdReview = {
        id: 'rev-1',
        ...createDto,
        customerId,
        status: 'ACTIVE',
      };

      repository.findDeliveredOrderForProduct.mockResolvedValue(deliveredOrder as any);
      repository.findByCustomerAndProduct.mockResolvedValue(null);
      repository.createWithTransaction.mockResolvedValue(createdReview as any);

      const result = await service.createReview(customerId, createDto);

      expect(result).toEqual(createdReview);
      expect(repository.createWithTransaction).toHaveBeenCalledWith({
        productId: createDto.productId,
        productVariantId: undefined,
        customerId,
        orderId: createDto.orderId,
        rating: createDto.rating,
        title: createDto.title,
        review: createDto.review,
        description: createDto.review,
        images: createDto.images,
      });
    });
  });

  describe('updateReview', () => {
    const customerId = 'cust-123';
    const reviewId = 'rev-1';

    it('should throw NotFoundException if review not found', async () => {
      repository.findById.mockResolvedValue(null);

      await expect(
        service.updateReview(customerId, reviewId, { rating: 4 }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw ForbiddenException if customer is not the review author', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        customerId: 'different-cust',
        productId: 'prod-123',
      } as any);

      await expect(
        service.updateReview(customerId, reviewId, { rating: 4 }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException if updated review text is < 10 characters', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        customerId,
        productId: 'prod-123',
      } as any);

      await expect(
        service.updateReview(customerId, reviewId, { review: 'Too short' }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should update review inside transaction', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        customerId,
        productId: 'prod-123',
        rating: 3,
      } as any);
      repository.updateWithTransaction.mockResolvedValue({ id: reviewId, rating: 5 } as any);

      const result = await service.updateReview(customerId, reviewId, { rating: 5 });

      expect(result).toEqual({ id: reviewId, rating: 5 });
      expect(repository.updateWithTransaction).toHaveBeenCalledWith(
        reviewId,
        'prod-123',
        expect.objectContaining({ rating: 5 }),
      );
    });
  });

  describe('deleteReview', () => {
    const customerId = 'cust-123';
    const reviewId = 'rev-1';

    it('should throw NotFoundException if review does not exist', async () => {
      repository.findById.mockResolvedValue(null);

      await expect(service.deleteReview(customerId, reviewId)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw ForbiddenException if customer is not the author', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        customerId: 'other-cust',
        productId: 'prod-123',
      } as any);

      await expect(service.deleteReview(customerId, reviewId)).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('should soft delete review with transaction and return confirmation', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        customerId,
        productId: 'prod-123',
      } as any);
      repository.deleteWithTransaction.mockResolvedValue({ id: reviewId } as any);

      const result = await service.deleteReview(customerId, reviewId);

      expect(result).toEqual({ message: 'Review deleted successfully' });
      expect(repository.deleteWithTransaction).toHaveBeenCalledWith(reviewId, 'prod-123');
    });
  });

  describe('getProductRatingSummary', () => {
    it('should return complete rating summary with star counts 1 to 5', async () => {
      const productId = 'prod-123';
      repository.getProductRatingSummary.mockResolvedValue({
        averageRating: 4.8,
        totalReviews: 10,
        ratingDistribution: { 1: 0, 2: 0, 3: 0, 4: 2, 5: 8 },
        fiveStarCount: 8,
        fourStarCount: 2,
        threeStarCount: 0,
        twoStarCount: 0,
        oneStarCount: 0,
      });

      const result = await service.getProductRatingSummary(productId);

      expect(result.productId).toBe(productId);
      expect(result.averageRating).toBe(4.8);
      expect(result.totalReviews).toBe(10);
      expect(result.fiveStarCount).toBe(8);
      expect(result.fourStarCount).toBe(2);
      expect(result.threeStarCount).toBe(0);
      expect(result.twoStarCount).toBe(0);
      expect(result.oneStarCount).toBe(0);
    });
  });

  describe('Vendor Reply workflow', () => {
    const vendorId = 'vendor-123';
    const reviewId = 'rev-1';

    it('should throw NotFoundException if review does not exist', async () => {
      repository.findById.mockResolvedValue(null);

      await expect(
        service.replyToReview(vendorId, reviewId, { reply: 'Thanks!' }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw ForbiddenException if vendor does not own the product', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        product: { vendorId: 'another-vendor' },
      } as any);

      await expect(
        service.replyToReview(vendorId, reviewId, { reply: 'Thanks!' }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw ConflictException if vendor has already replied (single reply constraint)', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        product: { vendorId },
        vendorReply: 'Previous reply exists.',
      } as any);

      await expect(
        service.replyToReview(vendorId, reviewId, { reply: 'Second reply' }),
      ).rejects.toThrow(ConflictException);
    });

    it('should record reply if vendor owns the product and has not replied yet', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        product: { vendorId },
        vendorReply: null,
      } as any);
      repository.setVendorReply.mockResolvedValue({
        id: reviewId,
        vendorReply: 'Thank you for your feedback!',
      } as any);

      const result = await service.replyToReview(vendorId, reviewId, {
        reply: 'Thank you for your feedback!',
      });

      expect(result).toBeDefined();
      expect(repository.setVendorReply).toHaveBeenCalledWith(
        reviewId,
        vendorId,
        'Thank you for your feedback!',
      );
    });
  });

  describe('Admin Review Moderation', () => {
    const reviewId = 'rev-1';

    it('should update review status to ACTIVE or HIDDEN with rating sync', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        productId: 'prod-123',
      } as any);
      repository.updateStatusWithTransaction.mockResolvedValue({
        id: reviewId,
        status: 'HIDDEN',
      } as any);

      const result = await service.updateReviewStatusByAdmin(reviewId, 'HIDDEN');

      expect(result.status).toBe('HIDDEN');
      expect(repository.updateStatusWithTransaction).toHaveBeenCalledWith(
        reviewId,
        'prod-123',
        'HIDDEN',
      );
    });

    it('should soft delete review by admin with rating sync', async () => {
      repository.findById.mockResolvedValue({
        id: reviewId,
        productId: 'prod-123',
      } as any);
      repository.deleteWithTransaction.mockResolvedValue({ id: reviewId } as any);

      const result = await service.deleteReviewByAdmin(reviewId);

      expect(result).toEqual({ message: 'Review removed by administrator' });
      expect(repository.deleteWithTransaction).toHaveBeenCalledWith(reviewId, 'prod-123');
    });
  });
});
