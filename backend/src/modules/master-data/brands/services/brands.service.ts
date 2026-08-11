import { Injectable, ConflictException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { IBrandsRepository } from '../interfaces/brands-repository.interface';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { UpdateBrandDto } from '../dto/update-brand.dto';

@Injectable()
export class BrandsService {
  constructor(private readonly brandsRepository: IBrandsRepository) {}

  async create(data: CreateBrandDto, vendorId: string) {
    const existing = await this.brandsRepository.findByName(data.name);
    if (existing && existing.status !== 'REJECTED') {
      throw new ConflictException(`Brand with name "${data.name}" already exists or is pending approval.`);
    }
    return this.brandsRepository.create(data, vendorId);
  }

  async findAllActive() {
    return this.brandsRepository.findMany({ status: 'ACTIVE' });
  }

  async findAllPending() {
    return this.brandsRepository.findMany({ status: 'PENDING' });
  }

  async findVendorBrands(vendorId: string) {
    return this.brandsRepository.findMany({ status: 'ACTIVE', createdByVendorId: vendorId });
  }

  async findOne(id: string) {
    const brand = await this.brandsRepository.findById(id);
    if (!brand) {
      throw new NotFoundException(`Brand with ID "${id}" not found.`);
    }
    return brand;
  }

  async updateByVendor(id: string, data: UpdateBrandDto, vendorId: string) {
    const brand = await this.findOne(id);
    if (brand.createdByVendorId !== vendorId) {
      throw new ForbiddenException('Access denied. You do not own this brand.');
    }

    if (data.name) {
      const existing = await this.brandsRepository.findByName(data.name);
      if (existing && existing.id !== id && existing.status !== 'REJECTED') {
        throw new ConflictException(`Brand with name "${data.name}" already exists.`);
      }
    }

    const updateData = {
      ...data,
      status: 'PENDING',
      approvedByAdminId: null,
      approvedAt: null,
      rejectedReason: null,
    };

    return this.brandsRepository.update(id, updateData, vendorId);
  }

  async approve(id: string, adminId: string) {
    const brand = await this.findOne(id);
    const updateData = {
      status: 'ACTIVE',
      approvedByAdminId: adminId,
      approvedAt: new Date(),
      rejectedReason: null,
    };
    return this.brandsRepository.update(brand.id, updateData, adminId);
  }

  async reject(id: string, adminId: string, reason: string) {
    const brand = await this.findOne(id);
    const updateData = {
      status: 'REJECTED',
      approvedByAdminId: adminId,
      approvedAt: new Date(),
      rejectedReason: reason,
    };
    return this.brandsRepository.update(brand.id, updateData, adminId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.brandsRepository.softDelete(id, userId);
  }
}
