import { Injectable } from '@nestjs/common';
import { ISubCategoriesRepository } from '../interfaces/sub-categories-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { SubCategoryEntity } from '../entities/sub-category.entity';
import { CreateSubCategoryDto } from '../dto/create-sub-category.dto';

@Injectable()
export class SubCategoriesRepository implements ISubCategoriesRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(subCategory: any): SubCategoryEntity {
    return new SubCategoryEntity({
      id: subCategory.id,
      categoryId: subCategory.categoryId,
      name: subCategory.name,
      description: subCategory.description,
      image: subCategory.image,
      sortOrder: subCategory.sortOrder,
      status: subCategory.status,
      createdAt: subCategory.createdAt,
      updatedAt: subCategory.updatedAt,
      deletedAt: subCategory.deletedAt,
      createdBy: subCategory.createdBy,
      updatedBy: subCategory.updatedBy,
      createdByVendorId: subCategory.createdByVendorId,
      approvedByAdminId: subCategory.approvedByAdminId,
      approvedAt: subCategory.approvedAt,
      rejectedReason: subCategory.rejectedReason,
    });
  }

  async create(data: CreateSubCategoryDto, vendorId: string): Promise<SubCategoryEntity> {
    const subCategory = await this.prisma.subCategory.create({
      data: {
        categoryId: data.categoryId,
        name: data.name,
        description: data.description,
        image: data.image,
        sortOrder: data.sortOrder ?? 0,
        status: 'PENDING',
        createdByVendorId: vendorId,
      },
    });
    return this.mapToEntity(subCategory);
  }

  async findMany(filters?: { categoryId?: string; status?: string; createdByVendorId?: string }): Promise<SubCategoryEntity[]> {
    const whereClause: any = { deletedAt: null };
    if (filters) {
      if (filters.categoryId) {
        whereClause.categoryId = filters.categoryId;
      }
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
    const subCategories = await this.prisma.subCategory.findMany({
      where: whereClause,
      orderBy: { sortOrder: 'asc' },
    });
    return subCategories.map((sc) => this.mapToEntity(sc));
  }

  async findById(id: string): Promise<SubCategoryEntity | null> {
    const subCategory = await this.prisma.subCategory.findFirst({
      where: { id, deletedAt: null },
    });
    return subCategory ? this.mapToEntity(subCategory) : null;
  }

  async findByNameAndCategory(name: string, categoryId: string): Promise<SubCategoryEntity | null> {
    const subCategory = await this.prisma.subCategory.findFirst({
      where: { name, categoryId, deletedAt: null },
    });
    return subCategory ? this.mapToEntity(subCategory) : null;
  }

  async update(id: string, data: any, userId: string): Promise<SubCategoryEntity> {
    const subCategory = await this.prisma.subCategory.update({
      where: { id },
      data: {
        categoryId: data.categoryId,
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
    return this.mapToEntity(subCategory);
  }

  async softDelete(id: string, userId: string): Promise<SubCategoryEntity> {
    const subCategory = await this.prisma.subCategory.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: 'INACTIVE',
        updatedBy: userId,
      },
    });
    return this.mapToEntity(subCategory);
  }
}
