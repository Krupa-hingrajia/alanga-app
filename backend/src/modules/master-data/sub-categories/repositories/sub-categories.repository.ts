import { Injectable } from '@nestjs/common';
import { ISubCategoriesRepository } from '../interfaces/sub-categories-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { SubCategoryEntity } from '../entities/sub-category.entity';
import { CreateSubCategoryDto } from '../dto/create-sub-category.dto';
import { UpdateSubCategoryDto } from '../dto/update-sub-category.dto';

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
    });
  }

  async create(data: CreateSubCategoryDto, userId: string): Promise<SubCategoryEntity> {
    const subCategory = await this.prisma.subCategory.create({
      data: {
        categoryId: data.categoryId,
        name: data.name,
        description: data.description,
        image: data.image,
        sortOrder: data.sortOrder ?? 0,
        status: data.status ?? 'ACTIVE',
        createdBy: userId,
      },
    });
    return this.mapToEntity(subCategory);
  }

  async findMany(categoryId?: string): Promise<SubCategoryEntity[]> {
    const subCategories = await this.prisma.subCategory.findMany({
      where: {
        deletedAt: null,
        ...(categoryId ? { categoryId } : {}),
      },
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

  async update(id: string, data: UpdateSubCategoryDto, userId: string): Promise<SubCategoryEntity> {
    const subCategory = await this.prisma.subCategory.update({
      where: { id },
      data: {
        categoryId: data.categoryId,
        name: data.name,
        description: data.description,
        image: data.image,
        sortOrder: data.sortOrder,
        status: data.status,
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
