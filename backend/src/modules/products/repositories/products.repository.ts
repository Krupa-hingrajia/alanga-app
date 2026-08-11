import { Injectable } from '@nestjs/common';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { ProductEntity } from '../entities/product.entity';
import { CreateProductDto } from '../dto/create-product.dto';

@Injectable()
export class ProductsRepository implements IProductsRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(product: any): ProductEntity {
    return new ProductEntity({
      id: product.id,
      name: product.name,
      description: product.description,
      shortDescription: product.shortDescription,
      categoryId: product.categoryId,
      subCategoryId: product.subCategoryId,
      brandId: product.brandId,
      sellingPrice: product.sellingPrice,
      mrp: product.mrp,
      taxPercentage: product.taxPercentage,
      stock: product.stock,
      weight: product.weight,
      length: product.length,
      width: product.width,
      height: product.height,
      sku: product.sku,
      status: product.status,
      vendorId: product.vendorId,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      deletedAt: product.deletedAt,
      createdBy: product.createdBy,
      updatedBy: product.updatedBy,
      createdByVendorId: product.createdByVendorId,
      approvedByAdminId: product.approvedByAdminId,
      approvedAt: product.approvedAt,
      rejectedReason: product.rejectedReason,
    });
  }

  private async generateNextSku(): Promise<string> {
    const lastProduct = await this.prisma.product.findFirst({
      where: {
        sku: {
          startsWith: 'ALA-PRD-',
        },
      },
      orderBy: {
        sku: 'desc',
      },
    });

    let nextNumber = 1;
    if (lastProduct && lastProduct.sku) {
      const parts = lastProduct.sku.split('-');
      const numStr = parts[parts.length - 1];
      const lastNum = parseInt(numStr, 10);
      if (!isNaN(lastNum)) {
        nextNumber = lastNum + 1;
      }
    }

    return `ALA-PRD-${String(nextNumber).padStart(6, '0')}`;
  }

  async create(data: CreateProductDto, vendorId: string): Promise<ProductEntity> {
    const sku = await this.generateNextSku();
    const product = await this.prisma.product.create({
      data: {
        name: data.name,
        description: data.description,
        shortDescription: data.shortDescription,
        categoryId: data.categoryId,
        subCategoryId: data.subCategoryId,
        brandId: data.brandId,
        sellingPrice: data.sellingPrice,
        mrp: data.mrp,
        taxPercentage: data.taxPercentage ?? 0,
        stock: data.stock ?? 0,
        weight: data.weight,
        length: data.length,
        width: data.width,
        height: data.height,
        sku: sku,
        status: data.status ?? 'DRAFT',
        vendorId: vendorId,
        createdByVendorId: vendorId,
      },
    });
    return this.mapToEntity(product);
  }

  async findMany(filters?: { status?: string; createdByVendorId?: string }): Promise<ProductEntity[]> {
    const whereClause: any = { deletedAt: null };
    if (filters) {
      if (filters.status && filters.createdByVendorId) {
        whereClause.OR = [
          { status: filters.status },
          { createdByVendorId: filters.createdByVendorId, deletedAt: null }
        ];
      } else if (filters.status) {
        whereClause.status = filters.status;
      } else if (filters.createdByVendorId) {
        whereClause.createdByVendorId = filters.createdByVendorId;
      }
    }
    const products = await this.prisma.product.findMany({
      where: whereClause,
      orderBy: { createdAt: 'desc' },
    });
    return products.map((p) => this.mapToEntity(p));
  }

  async findById(id: string): Promise<ProductEntity | null> {
    const product = await this.prisma.product.findFirst({
      where: { id, deletedAt: null },
    });
    return product ? this.mapToEntity(product) : null;
  }

  async update(id: string, data: any, userId: string): Promise<ProductEntity> {
    const product = await this.prisma.product.update({
      where: { id },
      data: {
        name: data.name,
        description: data.description,
        shortDescription: data.shortDescription,
        categoryId: data.categoryId,
        subCategoryId: data.subCategoryId,
        brandId: data.brandId,
        sellingPrice: data.sellingPrice,
        mrp: data.mrp,
        taxPercentage: data.taxPercentage,
        stock: data.stock,
        weight: data.weight,
        length: data.length,
        width: data.width,
        height: data.height,
        status: data.status,
        approvedByAdminId: data.approvedByAdminId,
        approvedAt: data.approvedAt,
        rejectedReason: data.rejectedReason,
        updatedBy: userId,
      },
    });
    return this.mapToEntity(product);
  }

  async softDelete(id: string, userId: string): Promise<ProductEntity> {
    const product = await this.prisma.product.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: 'INACTIVE',
        updatedBy: userId,
      },
    });
    return this.mapToEntity(product);
  }
}
