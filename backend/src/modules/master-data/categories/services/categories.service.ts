import { Injectable, ConflictException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { ICategoriesRepository } from '../interfaces/categories-repository.interface';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

@Injectable()
export class CategoriesService {
  constructor(private readonly categoriesRepository: ICategoriesRepository) {}

  async create(data: CreateCategoryDto, vendorId: string) {
    const existing = await this.categoriesRepository.findByName(data.name);
    if (existing && existing.status !== 'REJECTED') {
      throw new ConflictException(`Category with name "${data.name}" already exists or is pending approval.`);
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
    // Returns ACTIVE categories + vendor's own categories
    return this.categoriesRepository.findMany({ status: 'ACTIVE', createdByVendorId: vendorId });
  }

  async findOne(id: string) {
    const category = await this.categoriesRepository.findById(id);
    if (!category) {
      throw new NotFoundException(`Category with ID "${id}" not found.`);
    }
    return category;
  }

  async updateByVendor(id: string, data: UpdateCategoryDto, vendorId: string) {
    const category = await this.findOne(id);
    if (category.createdByVendorId !== vendorId) {
      throw new ForbiddenException('Access denied. You do not own this category.');
    }

    if (data.name) {
      const existing = await this.categoriesRepository.findByName(data.name);
      if (existing && existing.id !== id && existing.status !== 'REJECTED') {
        throw new ConflictException(`Category with name "${data.name}" already exists.`);
      }
    }

    // Whenever edited, reset status to PENDING
    const updateData = {
      ...data,
      status: 'PENDING',
      approvedByAdminId: null,
      approvedAt: null,
      rejectedReason: null,
    };

    return this.categoriesRepository.update(id, updateData, vendorId);
  }

  async approve(id: string, adminId: string) {
    const category = await this.findOne(id);
    const updateData = {
      status: 'ACTIVE',
      approvedByAdminId: adminId,
      approvedAt: new Date(),
      rejectedReason: null,
    };
    return this.categoriesRepository.update(category.id, updateData, adminId);
  }

  async reject(id: string, adminId: string, reason: string) {
    const category = await this.findOne(id);
    const updateData = {
      status: 'REJECTED',
      approvedByAdminId: adminId,
      approvedAt: new Date(),
      rejectedReason: reason,
    };
    return this.categoriesRepository.update(category.id, updateData, adminId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.categoriesRepository.softDelete(id, userId);
  }
}
