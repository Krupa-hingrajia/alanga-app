import { Injectable } from '@nestjs/common';
import { IBrandsRepository } from '../interfaces/brands-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { BrandEntity } from '../entities/brand.entity';
import { CreateBrandDto } from '../dto/create-brand.dto';

@Injectable()
export class BrandsRepository implements IBrandsRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(brand: any): BrandEntity {
    return new BrandEntity({
      id: brand.id,
      name: brand.name,
      logo: brand.logo,
      description: brand.description,
      status: brand.status,
      createdAt: brand.createdAt,
      updatedAt: brand.updatedAt,
      deletedAt: brand.deletedAt,
      createdBy: brand.createdBy,
      updatedBy: brand.updatedBy,
      createdByVendorId: brand.createdByVendorId,
      approvedByAdminId: brand.approvedByAdminId,
      approvedAt: brand.approvedAt,
      rejectedReason: brand.rejectedReason,
    });
  }

  async create(data: CreateBrandDto, vendorId: string): Promise<BrandEntity> {
    const brand = await this.prisma.brand.create({
      data: {
        name: data.name,
        logo: data.logo,
        description: data.description,
        status: 'PENDING',
        createdByVendorId: vendorId,
      },
    });
    return this.mapToEntity(brand);
  }

  async findMany(filters?: { status?: string; createdByVendorId?: string }): Promise<BrandEntity[]> {
    const whereClause: any = { deletedAt: null };
    if (filters) {
      if (filters.status && filters.createdByVendorId) {
        whereClause.OR = [
          { status: filters.status },
          { createdByVendorId: filters.createdByVendorId, deletedAt: null }
        ];
      } else if (filters.status) {
        whereClause.status = filters.status;
      } else if (filters.createdByVendorId) {
        whereClause.createdByVendorId = filters.createdByVendorId;
      }
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

  async update(id: string, data: any, userId: string): Promise<BrandEntity> {
    const brand = await this.prisma.brand.update({
      where: { id },
      data: {
        name: data.name,
        logo: data.logo,
        description: data.description,
        status: data.status,
        approvedByAdminId: data.approvedByAdminId,
        approvedAt: data.approvedAt,
        rejectedReason: data.rejectedReason,
        updatedBy: userId,
      },
    });
    return this.mapToEntity(brand);
  }

  async softDelete(id: string, userId: string): Promise<BrandEntity> {
    const brand = await this.prisma.brand.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: 'INACTIVE',
        updatedBy: userId,
      },
    });
    return this.mapToEntity(brand);
  }
}
