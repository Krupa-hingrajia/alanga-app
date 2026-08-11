import { Injectable } from '@nestjs/common';
import { IAttributesRepository } from '../interfaces/attributes-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { ProductAttributeEntity } from '../entities/attribute.entity';
import { CreateAttributeDto } from '../dto/create-attribute.dto';
import { UpdateAttributeDto } from '../dto/update-attribute.dto';

@Injectable()
export class AttributesRepository implements IAttributesRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(attribute: any): ProductAttributeEntity {
    return new ProductAttributeEntity({
      id: attribute.id,
      name: attribute.name,
      status: attribute.status,
      createdAt: attribute.createdAt,
      updatedAt: attribute.updatedAt,
      deletedAt: attribute.deletedAt,
      createdBy: attribute.createdBy,
      updatedBy: attribute.updatedBy,
    });
  }

  async create(data: CreateAttributeDto, userId: string): Promise<ProductAttributeEntity> {
    const attribute = await this.prisma.productAttribute.create({
      data: {
        name: data.name,
        status: data.status ?? 'ACTIVE',
        createdBy: userId,
      },
    });
    return this.mapToEntity(attribute);
  }

  async findMany(): Promise<ProductAttributeEntity[]> {
    const attributes = await this.prisma.productAttribute.findMany({
      where: { deletedAt: null },
      orderBy: { name: 'asc' },
    });
    return attributes.map((a) => this.mapToEntity(a));
  }

  async findById(id: string): Promise<ProductAttributeEntity | null> {
    const attribute = await this.prisma.productAttribute.findFirst({
      where: { id, deletedAt: null },
    });
    return attribute ? this.mapToEntity(attribute) : null;
  }

  async findByName(name: string): Promise<ProductAttributeEntity | null> {
    const attribute = await this.prisma.productAttribute.findFirst({
      where: { name, deletedAt: null },
    });
    return attribute ? this.mapToEntity(attribute) : null;
  }

  async update(id: string, data: UpdateAttributeDto, userId: string): Promise<ProductAttributeEntity> {
    const attribute = await this.prisma.productAttribute.update({
      where: { id },
      data: {
        name: data.name,
        status: data.status,
        updatedBy: userId,
      },
    });
    return this.mapToEntity(attribute);
  }

  async softDelete(id: string, userId: string): Promise<ProductAttributeEntity> {
    const attribute = await this.prisma.productAttribute.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: 'INACTIVE',
        updatedBy: userId,
      },
    });
    return this.mapToEntity(attribute);
  }
}
