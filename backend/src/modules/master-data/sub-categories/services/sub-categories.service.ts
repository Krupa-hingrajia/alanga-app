import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { ISubCategoriesRepository } from '../interfaces/sub-categories-repository.interface';
import { CategoriesService } from '../../categories/services/categories.service';
import { CreateSubCategoryDto } from '../dto/create-sub-category.dto';
import { UpdateSubCategoryDto } from '../dto/update-sub-category.dto';
import { AdminSubCategoryFilterDto } from '../dto/admin-sub-category-filter.dto';

@Injectable()
export class SubCategoriesService {
  constructor(
    private readonly subCategoriesRepository: ISubCategoriesRepository,
    private readonly categoriesService: CategoriesService,
  ) {}

  async findForAdmin(filters: AdminSubCategoryFilterDto) {
    return this.subCategoriesRepository.findForAdmin(filters);
  }

  async create(data: CreateSubCategoryDto, vendorId: string) {
    // Validate parent category exists
    await this.categoriesService.findOne(data.categoryId);

    // Validate unique subcategory name within this category
    const existing = await this.subCategoriesRepository.findByNameAndCategory(data.name, data.categoryId);
    if (existing) {
      throw new ConflictException(`SubCategory with name "${data.name}" already exists in this category.`);
    }

    return this.subCategoriesRepository.create(data, vendorId);
  }

  async findAllActive(categoryId?: string) {
    return this.subCategoriesRepository.findMany({ status: 'ACTIVE', categoryId });
  }

  async findAllPending(categoryId?: string) {
    return this.subCategoriesRepository.findMany({ status: 'PENDING', categoryId });
  }

  async findVendorSubCategories(vendorId: string, categoryId?: string) {
    return this.subCategoriesRepository.findMany({ status: 'ACTIVE', categoryId });
  }

  async findOne(id: string) {
    const subCategory = await this.subCategoriesRepository.findById(id);
    if (!subCategory) {
      throw new NotFoundException(`SubCategory with ID "${id}" not found.`);
    }
    return subCategory;
  }

  async updateByVendor(id: string, data: UpdateSubCategoryDto, vendorId: string) {
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

    return this.subCategoriesRepository.update(id, data, vendorId);
  }

  async approve(id: string, adminId: string) {
    const subCategory = await this.findOne(id);
    return this.subCategoriesRepository.update(subCategory.id, { isActive: true }, adminId);
  }

  async reject(id: string, adminId: string, reason: string) {
    const subCategory = await this.findOne(id);
    return this.subCategoriesRepository.update(subCategory.id, { isActive: false }, adminId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    const productCount = await this.subCategoriesRepository.countProducts(id);
    if (productCount > 0) {
      throw new ConflictException(
        'This sub-category cannot be deleted because it contains products. Please delete all products first.',
      );
    }
    return this.subCategoriesRepository.softDelete(id, userId);
  }

  async removeByVendor(id: string, vendorId: string) {
    await this.findOne(id);
    const productCount = await this.subCategoriesRepository.countProducts(id);
    if (productCount > 0) {
      throw new ConflictException(
        'This sub-category cannot be deleted because it contains products. Please delete all products first.',
      );
    }
    return this.subCategoriesRepository.softDelete(id, vendorId);
  }
}
