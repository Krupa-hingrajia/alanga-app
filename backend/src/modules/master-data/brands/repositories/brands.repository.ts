import { Injectable } from '@nestjs/common';
import { IBrandsRepository } from '../interfaces/brands-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { BrandEntity } from '../entities/brand.entity';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { UpdateBrandDto } from '../dto/update-brand.dto';

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
    });
  }

  async create(data: CreateBrandDto, userId: string): Promise<BrandEntity> {
    const brand = await this.prisma.brand.create({
      data: {
        name: data.name,
        logo: data.logo,
        description: data.description,
        status: data.status ?? 'ACTIVE',
        createdBy: userId,
      },
    });
    return this.mapToEntity(brand);
  }

  async findMany(): Promise<BrandEntity[]> {
    const brands = await this.prisma.brand.findMany({
      where: { deletedAt: null },
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

  async update(id: string, data: UpdateBrandDto, userId: string): Promise<BrandEntity> {
    const brand = await this.prisma.brand.update({
      where: { id },
      data: {
        name: data.name,
        logo: data.logo,
        description: data.description,
        status: data.status,
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
