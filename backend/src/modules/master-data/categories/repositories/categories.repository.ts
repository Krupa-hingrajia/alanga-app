import { Injectable } from '@nestjs/common';
import { ICategoriesRepository } from '../interfaces/categories-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { CategoryEntity } from '../entities/category.entity';
import { CreateCategoryDto } from '../dto/create-category.dto';

@Injectable()
export class CategoriesRepository implements ICategoriesRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(category: any): CategoryEntity {
    return new CategoryEntity({
      id: category.id,
      name: category.name,
      description: category.description,
      image: category.image,
      sortOrder: category.sortOrder,
      status: category.status,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      deletedAt: category.deletedAt,
      createdBy: category.createdBy,
      updatedBy: category.updatedBy,
      createdByVendorId: category.createdByVendorId,
      approvedByAdminId: category.approvedByAdminId,
      approvedAt: category.approvedAt,
      rejectedReason: category.rejectedReason,
    });
  }

  async create(data: CreateCategoryDto, vendorId: string): Promise<CategoryEntity> {
    const category = await this.prisma.category.create({
      data: {
        name: data.name,
        description: data.description,
        image: data.image,
        sortOrder: data.sortOrder ?? 0,
        status: 'PENDING',
        createdByVendorId: vendorId,
      },
    });
    return this.mapToEntity(category);
  }

  async findMany(filters?: { status?: string; createdByVendorId?: string }): Promise<CategoryEntity[]> {
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
    const categories = await this.prisma.category.findMany({
      where: whereClause,
      orderBy: { sortOrder: 'asc' },
    });
    return categories.map((c) => this.mapToEntity(c));
  }

  async findById(id: string): Promise<CategoryEntity | null> {
    const category = await this.prisma.category.findFirst({
      where: { id, deletedAt: null },
    });
    return category ? this.mapToEntity(category) : null;
  }

  async findByName(name: string): Promise<CategoryEntity | null> {
    const category = await this.prisma.category.findFirst({
      where: { name, deletedAt: null },
    });
    return category ? this.mapToEntity(category) : null;
  }

  async update(id: string, data: any, userId: string): Promise<CategoryEntity> {
    const category = await this.prisma.category.update({
      where: { id },
      data: {
        name: data.name,
        description: data.description,
        image: data.image,
        sortOrder: data.sortOrder,
        status: data.status,
        approvedByAdminId: data.approvedByAdminId,
        approvedAt: data.approvedAt,
        rejectedReason: data.rejectedReason,
        updatedBy: userId,
      },
    });
    return this.mapToEntity(category);
  }

  async softDelete(id: string, userId: string): Promise<CategoryEntity> {
    const category = await this.prisma.category.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: 'INACTIVE',
        updatedBy: userId,
      },
    });
    return this.mapToEntity(category);
  }
}
