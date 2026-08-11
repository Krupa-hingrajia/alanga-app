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
      price: product.price,
      stock: product.stock,
      isActive: product.isActive,
      vendorId: product.vendorId,
      status: product.status,
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

  async create(data: CreateProductDto, vendorId: string): Promise<ProductEntity> {
    const product = await this.prisma.product.create({
      data: {
        name: data.name,
        description: data.description,
        price: data.price,
        stock: data.stock,
        vendorId: vendorId,
        createdByVendorId: vendorId,
        status: 'PENDING',
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
        price: data.price,
        stock: data.stock,
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
