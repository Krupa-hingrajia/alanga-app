import { Injectable } from '@nestjs/common';
import { ISubCategoriesRepository } from '../interfaces/sub-categories-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { SubCategoryEntity } from '../entities/sub-category.entity';
import { CreateSubCategoryDto } from '../dto/create-sub-category.dto';
import { AdminSubCategoryFilterDto } from '../dto/admin-sub-category-filter.dto';

@Injectable()
export class SubCategoriesRepository implements ISubCategoriesRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(subCategory: any): SubCategoryEntity {
    return new SubCategoryEntity({
      id: subCategory.id,
      categoryId: subCategory.categoryId,
      name: subCategory.name,
      slug: subCategory.slug || '',
      description: subCategory.description,
      image: subCategory.image,
      isActive: subCategory.isActive ?? true,
      displayOrder: subCategory.displayOrder ?? 0,
      createdAt: subCategory.createdAt,
      updatedAt: subCategory.updatedAt,
      deletedAt: subCategory.deletedAt,
    });
  }

  async create(data: CreateSubCategoryDto, vendorId: string): Promise<SubCategoryEntity> {
    const slug = data.name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
    const subCategory = await this.prisma.subCategory.create({
      data: {
        categoryId: data.categoryId,
        name: data.name,
        slug,
        description: data.description,
        image: data.image,
        displayOrder: (data as any).sortOrder ?? 0,
      },
    });
    return this.mapToEntity(subCategory);
  }

  async findMany(filters?: { categoryId?: string; status?: string; createdByVendorId?: string }): Promise<SubCategoryEntity[]> {
    const whereClause: any = { deletedAt: null };
    if (filters) {
      if (filters.categoryId) whereClause.categoryId = filters.categoryId;
      if (filters.status === 'ACTIVE') whereClause.isActive = true;
      if (filters.status === 'INACTIVE') whereClause.isActive = false;
    }
    const subCategories = await this.prisma.subCategory.findMany({
      where: whereClause,
      orderBy: { displayOrder: 'asc' },
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
    const updateData: any = {};
    if (data.categoryId !== undefined) updateData.categoryId = data.categoryId;
    if (data.name !== undefined) updateData.name = data.name;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.image !== undefined) updateData.image = data.image;
    if (data.displayOrder !== undefined) updateData.displayOrder = data.displayOrder;
    if (data.sortOrder !== undefined) updateData.displayOrder = data.sortOrder;
    if (data.isActive !== undefined) updateData.isActive = data.isActive;

    const subCategory = await this.prisma.subCategory.update({
      where: { id },
      data: updateData,
    });
    return this.mapToEntity(subCategory);
  }

  async softDelete(id: string, userId: string): Promise<SubCategoryEntity> {
    const subCategory = await this.prisma.subCategory.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        isActive: false,
      },
    });
    return this.mapToEntity(subCategory);
  }

  async countProducts(subCategoryId: string): Promise<number> {
    return this.prisma.product.count({
      where: {
        subCategoryId,
        deletedAt: null,
      },
    });
  }

  async findForAdmin(filters: AdminSubCategoryFilterDto): Promise<{
    items: any[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters.page || 1;
    const limit = filters.limit || 10;
    const skip = (page - 1) * limit;

    const whereClause: any = { deletedAt: null };

    if (filters.status && filters.status.toUpperCase() === 'ACTIVE') {
      whereClause.isActive = true;
    } else if (filters.status && filters.status.toUpperCase() === 'INACTIVE') {
      whereClause.isActive = false;
    }

    if (filters.categoryId) {
      whereClause.categoryId = filters.categoryId;
    }

    if (filters.search) {
      whereClause.OR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { description: { contains: filters.search, mode: 'insensitive' } },
      ];
    }

    const [subCategories, total] = await Promise.all([
      this.prisma.subCategory.findMany({
        where: whereClause,
        skip,
        take: limit,
        include: {
          category: {
            select: {
              id: true,
              name: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.subCategory.count({ where: whereClause }),
    ]);

    const items = subCategories.map((subCategory) => ({
      ...this.mapToEntity(subCategory),
      category: (subCategory as any).category || null,
    }));

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }
}
