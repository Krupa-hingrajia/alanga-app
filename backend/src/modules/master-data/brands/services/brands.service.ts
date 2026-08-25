import { Injectable, ConflictException, NotFoundException, BadRequestException } from '@nestjs/common';
import { IBrandsRepository } from '../interfaces/brands-repository.interface';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { UpdateBrandDto } from '../dto/update-brand.dto';
import { RequestBrandDto } from '../dto/request-brand.dto';
import { AdminBrandFilterDto } from '../dto/admin-brand-filter.dto';

@Injectable()
export class BrandsService {
  constructor(private readonly brandsRepository: IBrandsRepository) {}

  async findForAdmin(filters: AdminBrandFilterDto) {
    return this.brandsRepository.findForAdmin(filters);
  }

  async createAdminBrand(data: CreateBrandDto, adminId?: string) {
    const existing = await this.brandsRepository.findByNameCaseInsensitive(data.name);
    if (existing) {
      throw new ConflictException(`Brand with name "${data.name}" already exists.`);
    }
    return this.brandsRepository.create(data, adminId);
  }

  async requestBrandByVendor(data: RequestBrandDto, vendorId: string) {
    const existing = await this.brandsRepository.findByNameCaseInsensitive(data.name);
    if (existing) {
      throw new ConflictException(`Brand with name "${data.name}" already exists.`);
    }
    return this.brandsRepository.createVendorRequest(data, vendorId);
  }

  async findActiveBrandsForVendor(search?: string) {
    return this.brandsRepository.findMany({ status: 'ACTIVE', search });
  }

  async findAllActive() {
    return this.brandsRepository.findMany({ status: 'ACTIVE' });
  }

  async findAllPending() {
    return this.brandsRepository.findMany({ status: 'PENDING' });
  }

  async findOne(id: string) {
    const brand = await this.brandsRepository.findById(id);
    if (!brand) {
      throw new NotFoundException(`Brand with ID "${id}" not found.`);
    }
    return brand;
  }

  async validateActiveBrandForProduct(id: string) {
    const brand = await this.findOne(id);
    if (brand.status !== 'ACTIVE' || !brand.isActive) {
      throw new BadRequestException('Selected brand is not active. Please select an active brand.');
    }
    return brand;
  }

  async updateAdminBrand(id: string, data: UpdateBrandDto, adminId: string) {
    await this.findOne(id);

    if (data.name) {
      const existing = await this.brandsRepository.findByNameCaseInsensitive(data.name);
      if (existing && existing.id !== id) {
        throw new ConflictException(`Brand with name "${data.name}" already exists.`);
      }
    }

    return this.brandsRepository.update(id, data, adminId);
  }

  async approve(id: string, adminId: string) {
    const brand = await this.findOne(id);
    return this.brandsRepository.update(
      brand.id,
      {
        status: 'ACTIVE',
        isActive: true,
        approvedByAdminId: adminId,
        approvedAt: new Date(),
        rejectedReason: null,
      },
      adminId,
    );
  }

  async reject(id: string, adminId: string, reason: string) {
    const brand = await this.findOne(id);
    return this.brandsRepository.update(
      brand.id,
      {
        status: 'REJECTED',
        isActive: false,
        approvedByAdminId: adminId,
        rejectedReason: reason,
      },
      adminId,
    );
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    const productCount = await this.brandsRepository.countProducts(id);
    if (productCount > 0) {
      throw new ConflictException(
        'This brand cannot be deleted because it is being used by one or more products.',
      );
    }
    return this.brandsRepository.softDelete(id, userId);
  }
}
