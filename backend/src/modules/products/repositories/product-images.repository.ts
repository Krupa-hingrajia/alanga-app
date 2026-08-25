import { Injectable } from '@nestjs/common';
import { IProductImagesRepository } from '../interfaces/product-images-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { ProductImageEntity } from '../entities/product-image.entity';

@Injectable()
export class ProductImagesRepository implements IProductImagesRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(image: any): ProductImageEntity {
    return new ProductImageEntity({
      id: image.id,
      productId: image.productId,
      productVariantId: image.productVariantId || null,
      imageUrl: image.imageUrl,
      isPrimary: image.isPrimary,
      displayOrder: image.displayOrder,
      createdAt: image.createdAt,
      updatedAt: image.updatedAt,
      deletedAt: image.deletedAt,
    });
  }

  async createMany(
    productId: string,
    images: Array<{ imageUrl: string; isPrimary: boolean; displayOrder: number; productVariantId?: string | null }>,
    productVariantId?: string,
  ): Promise<ProductImageEntity[]> {
    const createdImages = await this.prisma.$transaction(
      images.map((img) =>
        this.prisma.productImage.create({
          data: {
            productId,
            productVariantId: img.productVariantId || productVariantId || null,
            imageUrl: img.imageUrl,
            isPrimary: img.isPrimary,
            displayOrder: img.displayOrder,
          },
        }),
      ),
    );
    return createdImages.map((img) => this.mapToEntity(img));
  }

  async findByProductId(productId: string, productVariantId?: string): Promise<ProductImageEntity[]> {
    const where: any = {
      productId,
      deletedAt: null,
    };
    if (productVariantId !== undefined) {
      where.productVariantId = productVariantId || null;
    }

    const images = await this.prisma.productImage.findMany({
      where,
      orderBy: [
        { isPrimary: 'desc' },
        { displayOrder: 'asc' },
        { createdAt: 'asc' },
      ],
    });
    return images.map((img) => this.mapToEntity(img));
  }

  async findById(id: string): Promise<ProductImageEntity | null> {
    const image = await this.prisma.productImage.findFirst({
      where: {
        id,
        deletedAt: null,
      },
    });
    return image ? this.mapToEntity(image) : null;
  }

  async countActiveByProductId(productId: string, productVariantId?: string): Promise<number> {
    const where: any = {
      productId,
      deletedAt: null,
    };
    if (productVariantId !== undefined) {
      where.productVariantId = productVariantId || null;
    }

    return this.prisma.productImage.count({ where });
  }

  async getMaxDisplayOrder(productId: string, productVariantId?: string): Promise<number> {
    const where: any = {
      productId,
      deletedAt: null,
    };
    if (productVariantId !== undefined) {
      where.productVariantId = productVariantId || null;
    }

    const maxImg = await this.prisma.productImage.findFirst({
      where,
      orderBy: {
        displayOrder: 'desc',
      },
    });
    return maxImg ? maxImg.displayOrder : 0;
  }

  async setPrimaryImage(productId: string, imageId: string, productVariantId?: string): Promise<ProductImageEntity> {
    const where: any = {
      productId,
      deletedAt: null,
    };
    if (productVariantId !== undefined) {
      where.productVariantId = productVariantId || null;
    }

    const [, updated] = await this.prisma.$transaction([
      this.prisma.productImage.updateMany({
        where,
        data: {
          isPrimary: false,
        },
      }),
      this.prisma.productImage.update({
        where: {
          id: imageId,
        },
        data: {
          isPrimary: true,
        },
      }),
    ]);
    return this.mapToEntity(updated);
  }

  async softDelete(imageId: string): Promise<ProductImageEntity> {
    const deleted = await this.prisma.productImage.update({
      where: {
        id: imageId,
      },
      data: {
        deletedAt: new Date(),
        isPrimary: false,
      },
    });
    return this.mapToEntity(deleted);
  }

  async findFirstAvailable(productId: string, productVariantId?: string): Promise<ProductImageEntity | null> {
    const where: any = {
      productId,
      deletedAt: null,
    };
    if (productVariantId !== undefined) {
      where.productVariantId = productVariantId || null;
    }

    const image = await this.prisma.productImage.findFirst({
      where,
      orderBy: [
        { displayOrder: 'asc' },
        { createdAt: 'asc' },
      ],
    });
    return image ? this.mapToEntity(image) : null;
  }

  async updateDisplayOrders(
    productId: string,
    orders: Array<{ id: string; displayOrder: number }>,
  ): Promise<ProductImageEntity[]> {
    await this.prisma.$transaction(
      orders.map((item) =>
        this.prisma.productImage.update({
          where: { id: item.id },
          data: { displayOrder: item.displayOrder },
        }),
      ),
    );
    return this.findByProductId(productId);
  }
}
