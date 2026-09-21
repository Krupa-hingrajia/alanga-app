import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { ReviewQueryDto, AdminReviewQueryDto } from '../dto/review-query.dto';
import {
  IReviewRepository,
  RatingSummary,
  PaginatedReviews,
  CreateReviewData,
  UpdateReviewData,
} from '../interfaces/review-repository.interface';

@Injectable()
export class ReviewRepository implements IReviewRepository {
  constructor(private readonly prisma: PrismaService) {}

  private calculateSummaryFromRatings(reviews: { rating: number }[]): RatingSummary {
    const totalReviews = reviews.length;
    let sum = 0;
    const distribution: Record<number, number> = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };

    for (const r of reviews) {
      sum += r.rating;
      if (r.rating >= 1 && r.rating <= 5) {
        distribution[r.rating]++;
      }
    }

    const averageRating = totalReviews > 0 ? Math.round((sum / totalReviews) * 10) / 10 : 0;

    return {
      averageRating,
      totalReviews,
      ratingDistribution: distribution,
      fiveStarCount: distribution[5],
      fourStarCount: distribution[4],
      threeStarCount: distribution[3],
      twoStarCount: distribution[2],
      oneStarCount: distribution[1],
    };
  }

  async getProductRatingSummary(productId: string): Promise<RatingSummary> {
    const reviews = await this.prisma.review.findMany({
      where: {
        productId,
        deletedAt: null,
        status: { in: ['ACTIVE', 'PUBLISHED'] },
      },
      select: { rating: true },
    });

    return this.calculateSummaryFromRatings(reviews);
  }

  async createWithTransaction(data: CreateReviewData) {
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.review.findFirst({
        where: {
          customerId: data.customerId,
          productId: data.productId,
        },
      });

      const reviewText = data.review || data.description || '';
      const imagesJson = data.images ? JSON.stringify(data.images) : '[]';

      let reviewRecord;
      if (existing) {
        reviewRecord = await tx.review.update({
          where: { id: existing.id },
          data: {
            productVariantId: data.productVariantId || null,
            orderId: data.orderId,
            rating: data.rating,
            title: data.title || null,
            review: reviewText,
            description: reviewText,
            images: imagesJson,
            isVerifiedPurchase: true,
            deletedAt: null,
            status: 'ACTIVE',
          },
          include: {
            customer: {
              select: { id: true, fullName: true, profileImage: true },
            },
            product: {
              select: { id: true, name: true, image: true, vendorId: true },
            },
            productVariant: true,
          },
        });
      } else {
        reviewRecord = await tx.review.create({
          data: {
            productId: data.productId,
            productVariantId: data.productVariantId || null,
            customerId: data.customerId,
            orderId: data.orderId,
            rating: data.rating,
            title: data.title || null,
            review: reviewText,
            description: reviewText,
            images: imagesJson,
            isVerifiedPurchase: true,
            status: 'ACTIVE',
          },
          include: {
            customer: {
              select: { id: true, fullName: true, profileImage: true },
            },
            product: {
              select: { id: true, name: true, image: true, vendorId: true },
            },
            productVariant: true,
          },
        });
      }

      // Recalculate rating inside the same transaction
      const activeReviews = await tx.review.findMany({
        where: {
          productId: data.productId,
          deletedAt: null,
          status: { in: ['ACTIVE', 'PUBLISHED'] },
        },
        select: { rating: true },
      });

      const summary = this.calculateSummaryFromRatings(activeReviews);

      await tx.product.update({
        where: { id: data.productId },
        data: {
          averageRating: summary.averageRating,
          totalReviews: summary.totalReviews,
        },
      });

      return this.parseReviewImages(reviewRecord);
    });
  }

  async findById(id: string) {
    const review = await this.prisma.review.findFirst({
      where: { id },
      include: {
        customer: {
          select: {
            id: true,
            fullName: true,
            profileImage: true,
          },
        },
        product: {
          select: {
            id: true,
            name: true,
            image: true,
            vendorId: true,
          },
        },
        productVariant: true,
        replies: {
          where: { deletedAt: null },
          include: {
            vendor: {
              select: {
                id: true,
                fullName: true,
                profileImage: true,
              },
            },
          },
        },
      },
    });

    return this.parseReviewImages(review);
  }

  async findByCustomerAndProduct(customerId: string, productId: string, includeDeleted = false) {
    const review = await this.prisma.review.findFirst({
      where: {
        customerId,
        productId,
        ...(includeDeleted
          ? {}
          : {
              deletedAt: null,
              status: { not: 'DELETED' },
            }),
      },
    });

    return this.parseReviewImages(review);
  }

  async updateWithTransaction(id: string, productId: string, data: UpdateReviewData) {
    return this.prisma.$transaction(async (tx) => {
      const updateData: any = {};
      if (data.rating !== undefined) updateData.rating = data.rating;
      if (data.title !== undefined) updateData.title = data.title;
      if (data.review !== undefined) {
        updateData.review = data.review;
        updateData.description = data.review;
      } else if (data.description !== undefined) {
        updateData.review = data.description;
        updateData.description = data.description;
      }
      if (data.images !== undefined) updateData.images = JSON.stringify(data.images);
      if (data.deletedAt !== undefined) updateData.deletedAt = data.deletedAt;
      if (data.status !== undefined) updateData.status = data.status;

      const updated = await tx.review.update({
        where: { id },
        data: updateData,
        include: {
          customer: {
            select: { id: true, fullName: true, profileImage: true },
          },
          product: {
            select: { id: true, name: true, image: true, vendorId: true },
          },
          productVariant: true,
        },
      });

      if (data.rating !== undefined || data.status !== undefined) {
        const activeReviews = await tx.review.findMany({
          where: {
            productId,
            deletedAt: null,
            status: { in: ['ACTIVE', 'PUBLISHED'] },
          },
          select: { rating: true },
        });

        const summary = this.calculateSummaryFromRatings(activeReviews);

        await tx.product.update({
          where: { id: productId },
          data: {
            averageRating: summary.averageRating,
            totalReviews: summary.totalReviews,
          },
        });
      }

      return this.parseReviewImages(updated);
    });
  }

  async deleteWithTransaction(id: string, productId: string) {
    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.review.update({
        where: { id },
        data: {
          status: 'DELETED',
          deletedAt: new Date(),
        },
      });

      const activeReviews = await tx.review.findMany({
        where: {
          productId,
          deletedAt: null,
          status: { in: ['ACTIVE', 'PUBLISHED'] },
        },
        select: { rating: true },
      });

      const summary = this.calculateSummaryFromRatings(activeReviews);

      await tx.product.update({
        where: { id: productId },
        data: {
          averageRating: summary.averageRating,
          totalReviews: summary.totalReviews,
        },
      });

      return updated;
    });
  }

  async updateStatusWithTransaction(id: string, productId: string, status: string) {
    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.review.update({
        where: { id },
        data: {
          status,
          ...(status === 'DELETED' ? { deletedAt: new Date() } : {}),
          ...(status === 'ACTIVE' ? { deletedAt: null } : {}),
        },
        include: {
          customer: {
            select: { id: true, fullName: true, email: true },
          },
          product: {
            select: { id: true, name: true },
          },
        },
      });

      const activeReviews = await tx.review.findMany({
        where: {
          productId,
          deletedAt: null,
          status: { in: ['ACTIVE', 'PUBLISHED'] },
        },
        select: { rating: true },
      });

      const summary = this.calculateSummaryFromRatings(activeReviews);

      await tx.product.update({
        where: { id: productId },
        data: {
          averageRating: summary.averageRating,
          totalReviews: summary.totalReviews,
        },
      });

      return this.parseReviewImages(updated);
    });
  }

  async findByProduct(productId: string, query: ReviewQueryDto): Promise<PaginatedReviews> {
    const { page = 1, limit = 10, rating, sortBy = 'newest' } = query;
    const skip = (page - 1) * limit;

    const where: any = {
      productId,
      deletedAt: null,
      status: { in: ['ACTIVE', 'PUBLISHED'] },
    };

    if (rating) {
      where.rating = rating;
    }

    let orderBy: any = { createdAt: 'desc' };
    if (sortBy === 'highest_rating') {
      orderBy = { rating: 'desc' };
    } else if (sortBy === 'lowest_rating') {
      orderBy = { rating: 'asc' };
    }

    const [items, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          customer: {
            select: {
              id: true,
              fullName: true,
              profileImage: true,
            },
          },
          productVariant: {
            select: {
              id: true,
              variantName: true,
              sku: true,
            },
          },
          replies: {
            where: { deletedAt: null },
            include: {
              vendor: {
                select: {
                  id: true,
                  fullName: true,
                  profileImage: true,
                },
              },
            },
          },
        },
      }),
      this.prisma.review.count({ where }),
    ]);

    return {
      items: items.map(this.parseReviewImages),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findByCustomer(customerId: string, query: ReviewQueryDto): Promise<PaginatedReviews> {
    const { page = 1, limit = 10 } = query;
    const skip = (page - 1) * limit;

    const where = {
      customerId,
      deletedAt: null,
      status: { not: 'DELETED' },
    };

    const [items, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          product: {
            select: {
              id: true,
              name: true,
              image: true,
              vendor: {
                select: {
                  id: true,
                  fullName: true,
                },
              },
            },
          },
          productVariant: true,
          replies: {
            where: { deletedAt: null },
            include: {
              vendor: {
                select: {
                  id: true,
                  fullName: true,
                },
              },
            },
          },
        },
      }),
      this.prisma.review.count({ where }),
    ]);

    return {
      items: items.map(this.parseReviewImages),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findByVendor(vendorId: string, query: ReviewQueryDto): Promise<PaginatedReviews> {
    const { page = 1, limit = 10, rating } = query;
    const skip = (page - 1) * limit;

    const where: any = {
      product: { vendorId },
      deletedAt: null,
      status: { not: 'DELETED' },
    };

    if (rating) where.rating = rating;

    const [items, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          customer: {
            select: {
              id: true,
              fullName: true,
              profileImage: true,
            },
          },
          product: {
            select: {
              id: true,
              name: true,
              image: true,
            },
          },
          productVariant: true,
          replies: {
            where: { deletedAt: null },
          },
        },
      }),
      this.prisma.review.count({ where }),
    ]);

    return {
      items: items.map(this.parseReviewImages),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findAll(query: AdminReviewQueryDto): Promise<PaginatedReviews> {
    const { page = 1, limit = 10, rating, productId, vendorId, customerId, status, search } = query;
    const skip = (page - 1) * limit;

    const where: any = {};

    if (status) {
      where.status = status;
      if (status === 'DELETED') {
        where.deletedAt = { not: null };
      }
    } else {
      where.deletedAt = null;
    }

    if (rating) where.rating = rating;
    if (productId) where.productId = productId;
    if (customerId) where.customerId = customerId;
    if (vendorId) where.product = { vendorId };
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { review: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
        { product: { name: { contains: search, mode: 'insensitive' } } },
        { customer: { fullName: { contains: search, mode: 'insensitive' } } },
      ];
    }

    const [items, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          customer: {
            select: {
              id: true,
              fullName: true,
              email: true,
            },
          },
          product: {
            select: {
              id: true,
              name: true,
              image: true,
              vendor: {
                select: {
                  id: true,
                  fullName: true,
                  email: true,
                },
              },
            },
          },
          replies: {
            where: { deletedAt: null },
            include: {
              vendor: {
                select: {
                  id: true,
                  fullName: true,
                },
              },
            },
          },
        },
      }),
      this.prisma.review.count({ where }),
    ]);

    return {
      items: items.map(this.parseReviewImages),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async setVendorReply(reviewId: string, vendorId: string, reply: string) {
    return this.prisma.$transaction(async (tx) => {
      const updatedReview = await tx.review.update({
        where: { id: reviewId },
        data: {
          vendorReply: reply,
        },
      });

      // Also record in ReviewReply relation table for backward compatibility
      await tx.reviewReply.create({
        data: {
          reviewId,
          vendorId,
          reply,
        },
      });

      return updatedReview;
    });
  }

  async findReplyById(id: string) {
    return this.prisma.reviewReply.findFirst({
      where: { id, deletedAt: null },
    });
  }

  async updateReply(id: string, reply: string) {
    return this.prisma.reviewReply.update({
      where: { id },
      data: { reply },
    });
  }

  async deleteReply(id: string) {
    return this.prisma.reviewReply.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }

  async findDeliveredOrderForProduct(customerId: string, productId: string, orderId?: string) {
    const where: any = {
      customerId,
      deletedAt: null,
      orderItems: {
        some: {
          productId,
        },
      },
      OR: [
        { status: 'DELIVERED' },
        {
          orderItems: {
            some: {
              productId,
              status: 'DELIVERED',
            },
          },
        },
      ],
    };

    if (orderId) {
      where.id = orderId;
    }

    return this.prisma.order.findFirst({
      where,
      include: {
        orderItems: {
          where: { productId },
        },
      },
    });
  }

  async findEligibleProductsForReview(customerId: string) {
    const orders = await this.prisma.order.findMany({
      where: {
        customerId,
        deletedAt: null,
        OR: [
          { status: 'DELIVERED' },
          { orderItems: { some: { status: 'DELIVERED' } } },
        ],
      },
      include: {
        orderItems: {
          include: {
            product: {
              select: {
                id: true,
                name: true,
                image: true,
                vendor: {
                  select: {
                    id: true,
                    fullName: true,
                  },
                },
              },
            },
            productVariant: true,
          },
        },
      },
    });

    const existingReviews = await this.prisma.review.findMany({
      where: { customerId, deletedAt: null, status: { not: 'DELETED' } },
      select: { productId: true },
    });

    const reviewedProductIds = new Set(existingReviews.map((r) => r.productId));

    const eligibleMap = new Map<string, any>();
    for (const order of orders) {
      for (const item of order.orderItems) {
        const isItemDelivered =
          item.status === 'DELIVERED' || order.status === 'DELIVERED';
        if (isItemDelivered && !reviewedProductIds.has(item.productId)) {
          if (!eligibleMap.has(item.productId)) {
            eligibleMap.set(item.productId, {
              orderId: order.id,
              orderNumber: order.orderNumber,
              orderDate: order.createdAt,
              productId: item.productId,
              productName: item.productNameSnapshot,
              productImage: item.product?.image,
              variantId: item.productVariantId,
              variantName: item.variantNameSnapshot,
              vendorName: item.product?.vendor?.fullName || 'Marketplace Vendor',
            });
          }
        }
      }
    }

    return Array.from(eligibleMap.values());
  }

  private parseReviewImages(review: any) {
    if (!review) return review;
    let images: string[] = [];
    if (typeof review.images === 'string') {
      try {
        images = JSON.parse(review.images);
      } catch {
        images = [];
      }
    } else if (Array.isArray(review.images)) {
      images = review.images;
    }

    return {
      ...review,
      variantId: review.productVariantId || review.variantId || null,
      review: review.review || review.description || '',
      images,
    };
  }
}
