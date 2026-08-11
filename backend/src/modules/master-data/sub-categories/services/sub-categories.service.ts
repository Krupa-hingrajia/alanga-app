import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { ISubCategoriesRepository } from '../interfaces/sub-categories-repository.interface';
import { CategoriesService } from '../../categories/services/categories.service';
import { CreateSubCategoryDto } from '../dto/create-sub-category.dto';
import { UpdateSubCategoryDto } from '../dto/update-sub-category.dto';

@Injectable()
export class SubCategoriesService {
  constructor(
    private readonly subCategoriesRepository: ISubCategoriesRepository,
    private readonly categoriesService: CategoriesService,
  ) {}

  async create(data: CreateSubCategoryDto, userId: string) {
    // Validate parent category exists
    await this.categoriesService.findOne(data.categoryId);

    // Validate unique subcategory name within this category
    const existing = await this.subCategoriesRepository.findByNameAndCategory(data.name, data.categoryId);
    if (existing) {
      throw new ConflictException(`SubCategory with name "${data.name}" already exists in this category.`);
    }

    return this.subCategoriesRepository.create(data, userId);
  }

  async findAll(categoryId?: string) {
    if (categoryId) {
      await this.categoriesService.findOne(categoryId);
    }
    return this.subCategoriesRepository.findMany(categoryId);
  }

  async findOne(id: string) {
    const subCategory = await this.subCategoriesRepository.findById(id);
    if (!subCategory) {
      throw new NotFoundException(`SubCategory with ID "${id}" not found.`);
    }
    return subCategory;
  }

  async update(id: string, data: UpdateSubCategoryDto, userId: string) {
    const current = await this.findOne(id);

    const targetCategoryId = data.categoryId || current.categoryId;
    const targetName = data.name || current.name;

    // Validate parent category if category is changing
    if (data.categoryId && data.categoryId !== current.categoryId) {
      await this.categoriesService.findOne(data.categoryId);
    }

    // Validate uniqueness if name or category is changing
    if (data.name || data.categoryId) {
      const existing = await this.subCategoriesRepository.findByNameAndCategory(targetName, targetCategoryId);
      if (existing && existing.id !== id) {
        throw new ConflictException(`SubCategory with name "${targetName}" already exists in this category.`);
      }
    }

    return this.subCategoriesRepository.update(id, data, userId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.subCategoriesRepository.softDelete(id, userId);
  }
}
