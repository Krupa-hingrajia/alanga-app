import { Injectable } from '@nestjs/common';
import { IAttributeValuesRepository } from '../interfaces/attribute-values-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { AttributeValueEntity } from '../entities/attribute-value.entity';
import { CreateAttributeValueDto } from '../dto/create-attribute-value.dto';
import { UpdateAttributeValueDto } from '../dto/update-attribute-value.dto';

@Injectable()
export class AttributeValuesRepository implements IAttributeValuesRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(val: any): AttributeValueEntity {
    return new AttributeValueEntity({
      id: val.id,
      attributeId: val.attributeId,
      value: val.value,
      sortOrder: val.sortOrder,
      status: val.status,
      createdAt: val.createdAt,
      updatedAt: val.updatedAt,
      deletedAt: val.deletedAt,
      createdBy: val.createdBy,
      updatedBy: val.updatedBy,
    });
  }

  async create(data: CreateAttributeValueDto, userId: string): Promise<AttributeValueEntity> {
    const val = await this.prisma.attributeValue.create({
      data: {
        attributeId: data.attributeId,
        value: data.value,
        sortOrder: data.sortOrder ?? 0,
        status: data.status ?? 'ACTIVE',
        createdBy: userId,
      },
    });
    return this.mapToEntity(val);
  }

  async findMany(attributeId?: string): Promise<AttributeValueEntity[]> {
    const values = await this.prisma.attributeValue.findMany({
      where: {
        deletedAt: null,
        ...(attributeId ? { attributeId } : {}),
      },
      orderBy: { sortOrder: 'asc' },
    });
    return values.map((v) => this.mapToEntity(v));
  }

  async findById(id: string): Promise<AttributeValueEntity | null> {
    const val = await this.prisma.attributeValue.findFirst({
      where: { id, deletedAt: null },
    });
    return val ? this.mapToEntity(val) : null;
  }

  async findByValueAndAttribute(value: string, attributeId: string): Promise<AttributeValueEntity | null> {
    const val = await this.prisma.attributeValue.findFirst({
      where: { value, attributeId, deletedAt: null },
    });
    return val ? this.mapToEntity(val) : null;
  }

  async update(id: string, data: UpdateAttributeValueDto, userId: string): Promise<AttributeValueEntity> {
    const val = await this.prisma.attributeValue.update({
      where: { id },
      data: {
        attributeId: data.attributeId,
        value: data.value,
        sortOrder: data.sortOrder,
        status: data.status,
        updatedBy: userId,
      },
    });
    return this.mapToEntity(val);
  }

  async softDelete(id: string, userId: string): Promise<AttributeValueEntity> {
    const val = await this.prisma.attributeValue.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: 'INACTIVE',
        updatedBy: userId,
      },
    });
    return this.mapToEntity(val);
  }
}
