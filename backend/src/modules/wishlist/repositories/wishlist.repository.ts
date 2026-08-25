import { Injectable } from '@nestjs/common';
import { IWishlistRepository } from '../interfaces/wishlist-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { WishlistEntity } from '../entities/wishlist.entity';

@Injectable()
export class WishlistRepository implements IWishlistRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(item: any): WishlistEntity {
    return new WishlistEntity({
      id: item.id,
      customerId: item.customerId,
      productId: item.productId,
      productVariantId: item.productVariantId,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      product: item.product,
      productVariant: item.productVariant,
    });
  }

  async findByCustomer(customerId: string): Promise<WishlistEntity[]> {
    const items = await this.prisma.wishlist.findMany({
      where: { customerId },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null }, orderBy: { displayOrder: 'asc' } },
            productVariants: { where: { deletedAt: null } },
            brand: true,
            category: true,
            subCategory: true,
            shipping: true,
          },
        },
        productVariant: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    return items.map((i) => this.mapToEntity(i));
  }

  async findExisting(customerId: string, productId: string, productVariantId?: string): Promise<WishlistEntity | null> {
    const item = await this.prisma.wishlist.findFirst({
      where: {
        customerId,
        productId,
        productVariantId: productVariantId ?? null,
      },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null }, orderBy: { displayOrder: 'asc' } },
            productVariants: { where: { deletedAt: null } },
            brand: true,
            category: true,
            subCategory: true,
            shipping: true,
          },
        },
        productVariant: true,
      },
    });

    return item ? this.mapToEntity(item) : null;
  }

  async findByCustomerAndProduct(customerId: string, productId: string): Promise<WishlistEntity | null> {
    const item = await this.prisma.wishlist.findFirst({
      where: {
        customerId,
        productId,
      },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null }, orderBy: { displayOrder: 'asc' } },
            productVariants: { where: { deletedAt: null } },
            brand: true,
            category: true,
            subCategory: true,
            shipping: true,
          },
        },
        productVariant: true,
      },
    });

    return item ? this.mapToEntity(item) : null;
  }

  async findById(id: string): Promise<WishlistEntity | null> {
    const item = await this.prisma.wishlist.findUnique({
      where: { id },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null }, orderBy: { displayOrder: 'asc' } },
            productVariants: { where: { deletedAt: null } },
            brand: true,
            category: true,
            subCategory: true,
            shipping: true,
          },
        },
        productVariant: true,
      },
    });

    return item ? this.mapToEntity(item) : null;
  }

  async create(customerId: string, productId: string, productVariantId?: string): Promise<WishlistEntity> {
    const created = await this.prisma.wishlist.create({
      data: {
        customerId,
        productId,
        productVariantId: productVariantId ?? null,
      },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null }, orderBy: { displayOrder: 'asc' } },
            productVariants: { where: { deletedAt: null } },
            brand: true,
            category: true,
            subCategory: true,
            shipping: true,
          },
        },
        productVariant: true,
      },
    });

    return this.mapToEntity(created);
  }

  async updateVariant(id: string, productVariantId: string | null): Promise<WishlistEntity> {
    const updated = await this.prisma.wishlist.update({
      where: { id },
      data: {
        productVariantId: productVariantId ?? null,
      },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null }, orderBy: { displayOrder: 'asc' } },
            productVariants: { where: { deletedAt: null } },
            brand: true,
            category: true,
            subCategory: true,
            shipping: true,
          },
        },
        productVariant: true,
      },
    });

    return this.mapToEntity(updated);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.wishlist.delete({
      where: { id },
    });
  }
}
