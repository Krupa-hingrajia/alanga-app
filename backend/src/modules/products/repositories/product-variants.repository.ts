import { Injectable } from '@nestjs/common';
import { IProductVariantsRepository } from '../interfaces/product-variants-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { ProductVariantEntity } from '../entities/product-variant.entity';
import { CreateProductVariantDto } from '../dto/create-product-variant.dto';
import { UpdateProductVariantDto } from '../dto/update-product-variant.dto';

@Injectable()
export class ProductVariantsRepository implements IProductVariantsRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(variant: any): ProductVariantEntity {
    return new ProductVariantEntity({
      id: variant.id,
      productId: variant.productId,
      sku: variant.sku,
      variantName: variant.variantName,
      color: variant.color,
      size: variant.size,
      storage: variant.storage,
      price: variant.price,
      stock: variant.stock,
      status: variant.status,
      createdAt: variant.createdAt,
      updatedAt: variant.updatedAt,
      deletedAt: variant.deletedAt,
      images: variant.images || variant.productImages || [],
    });
  }

  async create(
    productId: string,
    data: CreateProductVariantDto,
  ): Promise<ProductVariantEntity> {
    const created = await this.prisma.productVariant.create({
      data: {
        productId,
        sku: data.sku,
        variantName: data.variantName,
        color: data.color || null,
        size: data.size || null,
        storage: data.storage || null,
        price: data.price,
        stock: data.stock,
        status: data.status || 'ACTIVE',
      },
      include: {
        images: {
          where: { deletedAt: null },
          orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }],
        },
      },
    });
    return this.mapToEntity(created);
  }

  async findByProductId(productId: string): Promise<ProductVariantEntity[]> {
    const variants = await this.prisma.productVariant.findMany({
      where: {
        productId,
        deletedAt: null,
      },
      include: {
        images: {
          where: { deletedAt: null },
          orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }],
        },
      },
      orderBy: {
        createdAt: 'asc',
      },
    });
    return variants.map((v) => this.mapToEntity(v));
  }

  async findById(id: string): Promise<ProductVariantEntity | null> {
    const variant = await this.prisma.productVariant.findFirst({
      where: {
        id,
        deletedAt: null,
      },
      include: {
        images: {
          where: { deletedAt: null },
          orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }],
        },
      },
    });
    return variant ? this.mapToEntity(variant) : null;
  }

  async findBySku(sku: string): Promise<ProductVariantEntity | null> {
    const variant = await this.prisma.productVariant.findFirst({
      where: {
        sku,
        deletedAt: null,
      },
      include: {
        images: {
          where: { deletedAt: null },
          orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }],
        },
      },
    });
    return variant ? this.mapToEntity(variant) : null;
  }

  async update(
    id: string,
    data: UpdateProductVariantDto,
  ): Promise<ProductVariantEntity> {
    const updated = await this.prisma.productVariant.update({
      where: {
        id,
      },
      data: {
        ...(data.variantName !== undefined && { variantName: data.variantName }),
        ...(data.sku !== undefined && { sku: data.sku }),
        ...(data.color !== undefined && { color: data.color }),
        ...(data.size !== undefined && { size: data.size }),
        ...(data.storage !== undefined && { storage: data.storage }),
        ...(data.price !== undefined && { price: data.price }),
        ...(data.stock !== undefined && { stock: data.stock }),
        ...(data.status !== undefined && { status: data.status }),
      },
      include: {
        images: {
          where: { deletedAt: null },
          orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }],
        },
      },
    });
    return this.mapToEntity(updated);
  }

  async softDelete(id: string): Promise<ProductVariantEntity> {
    const deleted = await this.prisma.productVariant.update({
      where: {
        id,
      },
      data: {
        deletedAt: new Date(),
        status: 'INACTIVE',
      },
      include: {
        images: {
          where: { deletedAt: null },
          orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }],
        },
      },
    });
    return this.mapToEntity(deleted);
  }
}
