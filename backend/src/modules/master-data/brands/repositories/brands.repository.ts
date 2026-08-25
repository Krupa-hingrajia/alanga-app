import { Injectable } from '@nestjs/common';
import { IBrandsRepository } from '../interfaces/brands-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { BrandEntity } from '../entities/brand.entity';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { RequestBrandDto } from '../dto/request-brand.dto';
import { AdminBrandFilterDto } from '../dto/admin-brand-filter.dto';

@Injectable()
export class BrandsRepository implements IBrandsRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(brand: any): BrandEntity {
    return new BrandEntity({
      id: brand.id,
      name: brand.name,
      slug: brand.slug || '',
      logo: brand.logo,
      description: brand.description,
      website: brand.website,
      status: brand.status || (brand.isActive ? 'ACTIVE' : 'INACTIVE'),
      isActive: brand.isActive ?? true,
      displayOrder: brand.displayOrder ?? 0,
      createdByVendorId: brand.createdByVendorId || null,
      approvedByAdminId: brand.approvedByAdminId || null,
      approvedAt: brand.approvedAt || null,
      rejectedReason: brand.rejectedReason || null,
      createdAt: brand.createdAt,
      updatedAt: brand.updatedAt,
      deletedAt: brand.deletedAt,
    });
  }

  async create(data: CreateBrandDto, vendorId?: string): Promise<BrandEntity> {
    const slug = data.name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
    const brand = await this.prisma.brand.create({
      data: {
        name: data.name,
        slug,
        logo: data.logo,
        description: data.description,
        status: 'ACTIVE',
        isActive: true,
        createdByVendorId: vendorId || null,
      },
    });
    return this.mapToEntity(brand);
  }

  async createVendorRequest(data: RequestBrandDto, vendorId: string): Promise<BrandEntity> {
    const slug = data.name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
    const brand = await this.prisma.brand.create({
      data: {
        name: data.name,
        slug,
        logo: data.logo,
        description: data.description,
        status: 'PENDING',
        isActive: false,
        createdByVendorId: vendorId,
      },
    });
    return this.mapToEntity(brand);
  }

  async findMany(filters?: { status?: string; search?: string }): Promise<BrandEntity[]> {
    const whereClause: any = { deletedAt: null };

    if (filters?.status) {
      const statusUpper = filters.status.toUpperCase();
      if (statusUpper === 'ACTIVE') {
        whereClause.status = 'ACTIVE';
        whereClause.isActive = true;
      } else if (statusUpper === 'INACTIVE') {
        whereClause.OR = [{ status: 'INACTIVE' }, { isActive: false }];
      } else {
        whereClause.status = statusUpper;
      }
    }

    if (filters?.search && filters.search.trim()) {
      whereClause.name = { contains: filters.search.trim(), mode: 'insensitive' };
    }

    const brands = await this.prisma.brand.findMany({
      where: whereClause,
      orderBy: { name: 'asc' },
    });
    return brands.map((b) => this.mapToEntity(b));
  }

  async findById(id: string): Promise<BrandEntity | null> {
    const brand = await this.prisma.brand.findFirst({
      where: { id, deletedAt: null },
    });
    return brand ? this.mapToEntity(brand) : null;
  }

  async findByName(name: string): Promise<BrandEntity | null> {
    const brand = await this.prisma.brand.findFirst({
      where: { name, deletedAt: null },
    });
    return brand ? this.mapToEntity(brand) : null;
  }

  async findByNameCaseInsensitive(name: string): Promise<BrandEntity | null> {
    const brand = await this.prisma.brand.findFirst({
      where: {
        name: { equals: name, mode: 'insensitive' },
        deletedAt: null,
      },
    });
    return brand ? this.mapToEntity(brand) : null;
  }

  async update(id: string, data: any, userId: string): Promise<BrandEntity> {
    const updateData: any = {};
    if (data.name !== undefined) {
      updateData.name = data.name;
      updateData.slug = data.name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
    }
    if (data.logo !== undefined) updateData.logo = data.logo;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.website !== undefined) updateData.website = data.website;
    if (data.status !== undefined) updateData.status = data.status;
    if (data.isActive !== undefined) updateData.isActive = data.isActive;
    if (data.displayOrder !== undefined) updateData.displayOrder = data.displayOrder;
    if (data.approvedByAdminId !== undefined) updateData.approvedByAdminId = data.approvedByAdminId;
    if (data.approvedAt !== undefined) updateData.approvedAt = data.approvedAt;
    if (data.rejectedReason !== undefined) updateData.rejectedReason = data.rejectedReason;

    const brand = await this.prisma.brand.update({
      where: { id },
      data: updateData,
    });
    return this.mapToEntity(brand);
  }

  async softDelete(id: string, userId: string): Promise<BrandEntity> {
    const brand = await this.prisma.brand.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        isActive: false,
      },
    });
    return this.mapToEntity(brand);
  }

  async countProducts(brandId: string): Promise<number> {
    return this.prisma.product.count({
      where: {
        brandId,
        deletedAt: null,
      },
    });
  }

  async findForAdmin(filters: AdminBrandFilterDto): Promise<{
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

    if (filters.status) {
      const statusUpper = filters.status.toUpperCase();
      if (statusUpper === 'ACTIVE') {
        whereClause.status = 'ACTIVE';
        whereClause.isActive = true;
      } else if (statusUpper === 'INACTIVE') {
        whereClause.OR = [{ status: 'INACTIVE' }, { isActive: false }];
      } else {
        whereClause.status = statusUpper;
      }
    }

    if (filters.search && filters.search.trim()) {
      whereClause.OR = [
        { name: { contains: filters.search.trim(), mode: 'insensitive' } },
        { description: { contains: filters.search.trim(), mode: 'insensitive' } },
      ];
    }

    const [brands, total] = await Promise.all([
      this.prisma.brand.findMany({
        where: whereClause,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.brand.count({ where: whereClause }),
    ]);

    const items = brands.map((brand) => ({
      ...this.mapToEntity(brand),
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
