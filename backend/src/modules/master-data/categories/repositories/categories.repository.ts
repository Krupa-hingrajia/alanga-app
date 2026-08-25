import { Injectable } from '@nestjs/common';
import { ICategoriesRepository } from '../interfaces/categories-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { CategoryEntity } from '../entities/category.entity';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { AdminCategoryFilterDto } from '../dto/admin-category-filter.dto';

@Injectable()
export class CategoriesRepository implements ICategoriesRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(category: any): CategoryEntity {
    return new CategoryEntity({
      id: category.id,
      name: category.name,
      slug: category.slug || '',
      description: category.description,
      image: category.image,
      isActive: category.isActive ?? true,
      displayOrder: category.displayOrder ?? 0,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      deletedAt: category.deletedAt,
    });
  }

  async create(data: CreateCategoryDto, vendorId: string): Promise<CategoryEntity> {
    const slug = data.name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
    const category = await this.prisma.category.create({
      data: {
        name: data.name,
        slug,
        description: data.description,
        image: data.image,
        displayOrder: (data as any).sortOrder ?? 0,
      },
    });
    return this.mapToEntity(category);
  }

  async findMany(filters?: { status?: string; createdByVendorId?: string }): Promise<CategoryEntity[]> {
    const whereClause: any = { deletedAt: null };
    if (filters?.status === 'ACTIVE') {
      whereClause.isActive = true;
    } else if (filters?.status === 'INACTIVE') {
      whereClause.isActive = false;
    }
    const categories = await this.prisma.category.findMany({
      where: whereClause,
      orderBy: { displayOrder: 'asc' },
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
    const updateData: any = {};
    if (data.name !== undefined) updateData.name = data.name;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.image !== undefined) updateData.image = data.image;
    if (data.displayOrder !== undefined) updateData.displayOrder = data.displayOrder;
    if (data.sortOrder !== undefined) updateData.displayOrder = data.sortOrder;
    if (data.isActive !== undefined) updateData.isActive = data.isActive;

    const category = await this.prisma.category.update({
      where: { id },
      data: updateData,
    });
    return this.mapToEntity(category);
  }

  async softDelete(id: string, userId: string): Promise<CategoryEntity> {
    const category = await this.prisma.category.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        isActive: false,
      },
    });
    return this.mapToEntity(category);
  }

  async countSubCategories(categoryId: string): Promise<number> {
    return this.prisma.subCategory.count({
      where: {
        categoryId,
        deletedAt: null,
      },
    });
  }

  async findForAdmin(filters: AdminCategoryFilterDto): Promise<{
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

    if (filters.search) {
      whereClause.OR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { description: { contains: filters.search, mode: 'insensitive' } },
      ];
    }

    const [categories, total] = await Promise.all([
      this.prisma.category.findMany({
        where: whereClause,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.category.count({ where: whereClause }),
    ]);

    const items = categories.map((category) => ({
      ...this.mapToEntity(category),
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
