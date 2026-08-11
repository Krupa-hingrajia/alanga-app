import { Injectable, ConflictException, NotFoundException, ForbiddenException } from '@nestjs/common';
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

  async create(data: CreateSubCategoryDto, vendorId: string) {
    // Validate parent category exists
    await this.categoriesService.findOne(data.categoryId);

    // Validate unique subcategory name within this category
    const existing = await this.subCategoriesRepository.findByNameAndCategory(data.name, data.categoryId);
    if (existing && existing.status !== 'REJECTED') {
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
    return this.subCategoriesRepository.findMany({ status: 'ACTIVE', createdByVendorId: vendorId, categoryId });
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
    if (current.createdByVendorId !== vendorId) {
      throw new ForbiddenException('Access denied. You do not own this subcategory.');
    }

    const targetCategoryId = data.categoryId || current.categoryId;
    const targetName = data.name || current.name;

    // Validate parent category if category is changing
    if (data.categoryId && data.categoryId !== current.categoryId) {
      await this.categoriesService.findOne(data.categoryId);
    }

    // Validate uniqueness if name or category is changing
    if (data.name || data.categoryId) {
      const existing = await this.subCategoriesRepository.findByNameAndCategory(targetName, targetCategoryId);
      if (existing && existing.id !== id && existing.status !== 'REJECTED') {
        throw new ConflictException(`SubCategory with name "${targetName}" already exists in this category.`);
      }
    }

    const updateData = {
      ...data,
      status: 'PENDING',
      approvedByAdminId: null,
      approvedAt: null,
      rejectedReason: null,
    };

    return this.subCategoriesRepository.update(id, updateData, vendorId);
  }

  async approve(id: string, adminId: string) {
    const subCategory = await this.findOne(id);
    const updateData = {
      status: 'ACTIVE',
      approvedByAdminId: adminId,
      approvedAt: new Date(),
      rejectedReason: null,
    };
    return this.subCategoriesRepository.update(subCategory.id, updateData, adminId);
  }

  async reject(id: string, adminId: string, reason: string) {
    const subCategory = await this.findOne(id);
    const updateData = {
      status: 'REJECTED',
      approvedByAdminId: adminId,
      approvedAt: new Date(),
      rejectedReason: reason,
    };
    return this.subCategoriesRepository.update(subCategory.id, updateData, adminId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.subCategoriesRepository.softDelete(id, userId);
  }
}
