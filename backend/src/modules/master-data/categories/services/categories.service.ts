import { Injectable, ConflictException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { ICategoriesRepository } from '../interfaces/categories-repository.interface';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';
import { AdminCategoryFilterDto } from '../dto/admin-category-filter.dto';

@Injectable()
export class CategoriesService {
  constructor(private readonly categoriesRepository: ICategoriesRepository) {}

  async findForAdmin(filters: AdminCategoryFilterDto) {
    return this.categoriesRepository.findForAdmin(filters);
  }

  async create(data: CreateCategoryDto, vendorId: string) {
    const existing = await this.categoriesRepository.findByName(data.name);
    if (existing) {
      throw new ConflictException(`Category with name "${data.name}" already exists.`);
    }
    return this.categoriesRepository.create(data, vendorId);
  }

  async findAllActive() {
    return this.categoriesRepository.findMany({ status: 'ACTIVE' });
  }

  async findAllPending() {
    return this.categoriesRepository.findMany({ status: 'PENDING' });
  }

  async findVendorCategories(vendorId: string) {
    return this.categoriesRepository.findMany({ status: 'ACTIVE' });
  }

  async findOne(id: string) {
    const category = await this.categoriesRepository.findById(id);
    if (!category) {
      throw new NotFoundException(`Category with ID "${id}" not found.`);
    }
    return category;
  }

  async updateByVendor(id: string, data: UpdateCategoryDto, vendorId: string) {
    await this.findOne(id);

    if (data.name) {
      const existing = await this.categoriesRepository.findByName(data.name);
      if (existing && existing.id !== id) {
        throw new ConflictException(`Category with name "${data.name}" already exists.`);
      }
    }

    return this.categoriesRepository.update(id, data, vendorId);
  }

  async approve(id: string, adminId: string) {
    const category = await this.findOne(id);
    return this.categoriesRepository.update(category.id, { isActive: true }, adminId);
  }

  async reject(id: string, adminId: string, reason: string) {
    const category = await this.findOne(id);
    return this.categoriesRepository.update(category.id, { isActive: false }, adminId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    const subCategoryCount = await this.categoriesRepository.countSubCategories(id);
    if (subCategoryCount > 0) {
      throw new ConflictException(
        'This category cannot be deleted because it contains sub-categories. Please delete all sub-categories first.',
      );
    }
    return this.categoriesRepository.softDelete(id, userId);
  }

  async removeByVendor(id: string, vendorId: string) {
    await this.findOne(id);
    const subCategoryCount = await this.categoriesRepository.countSubCategories(id);
    if (subCategoryCount > 0) {
      throw new ConflictException(
        'This category cannot be deleted because it contains sub-categories. Please delete all sub-categories first.',
      );
    }
    return this.categoriesRepository.softDelete(id, vendorId);
  }
}
