import { Injectable } from '@nestjs/common';
import { ICategoriesRepository } from '../interfaces/categories-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { CategoryEntity } from '../entities/category.entity';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

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
    });
  }

  async create(data: CreateCategoryDto, userId: string): Promise<CategoryEntity> {
    const category = await this.prisma.category.create({
      data: {
        name: data.name,
        description: data.description,
        image: data.image,
        sortOrder: data.sortOrder ?? 0,
        status: data.status ?? 'ACTIVE',
        createdBy: userId,
      },
    });
    return this.mapToEntity(category);
  }

  async findMany(): Promise<CategoryEntity[]> {
    const categories = await this.prisma.category.findMany({
      where: { deletedAt: null },
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

  async update(id: string, data: UpdateCategoryDto, userId: string): Promise<CategoryEntity> {
    const category = await this.prisma.category.update({
      where: { id },
      data: {
        name: data.name,
        description: data.description,
        image: data.image,
        sortOrder: data.sortOrder,
        status: data.status,
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
