import { Injectable } from '@nestjs/common';
import { IAttributeValuesRepository } from '../interfaces/attribute-values-repository.interface';
import { AttributeValueEntity } from '../entities/attribute-value.entity';
import { CreateAttributeValueDto } from '../dto/create-attribute-value.dto';
import { UpdateAttributeValueDto } from '../dto/update-attribute-value.dto';

/**
 * NOTE: 'AttributeValue' model does not exist in the Prisma schema yet.
 * This is a stub repository using in-memory storage until the schema is updated.
 */
@Injectable()
export class AttributeValuesRepository implements IAttributeValuesRepository {
  private values: AttributeValueEntity[] = [];
  private idCounter = 1;

  private makeId(): string {
    return `av-${this.idCounter++}-${Date.now()}`;
  }

  async create(data: CreateAttributeValueDto, userId: string): Promise<AttributeValueEntity> {
    const now = new Date();
    const val = new AttributeValueEntity({
      id: this.makeId(),
      attributeId: data.attributeId,
      value: data.value,
      sortOrder: 0,
      status: 'ACTIVE',
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      createdBy: userId,
      updatedBy: userId,
    });
    this.values.push(val);
    return val;
  }

  async findMany(attributeId?: string): Promise<AttributeValueEntity[]> {
    return this.values.filter((v) => !v.deletedAt && (!attributeId || v.attributeId === attributeId));
  }

  async findById(id: string): Promise<AttributeValueEntity | null> {
    return this.values.find((v) => v.id === id && !v.deletedAt) || null;
  }

  async findByValueAndAttribute(value: string, attributeId: string): Promise<AttributeValueEntity | null> {
    return this.values.find((v) => v.value === value && v.attributeId === attributeId && !v.deletedAt) || null;
  }

  async update(id: string, data: UpdateAttributeValueDto, userId: string): Promise<AttributeValueEntity> {
    const val = this.values.find((v) => v.id === id);
    if (!val) throw new Error(`AttributeValue not found: ${id}`);
    if (data.attributeId !== undefined) val.attributeId = data.attributeId;
    if (data.value !== undefined) val.value = data.value;
    val.updatedBy = userId;
    val.updatedAt = new Date();
    return val;
  }

  async softDelete(id: string, userId: string): Promise<AttributeValueEntity> {
    const val = this.values.find((v) => v.id === id);
    if (!val) throw new Error(`AttributeValue not found: ${id}`);
    val.deletedAt = new Date();
    val.updatedBy = userId;
    val.updatedAt = new Date();
    return val;
  }
}
