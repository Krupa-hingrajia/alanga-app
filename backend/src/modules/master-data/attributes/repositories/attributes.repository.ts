import { Injectable } from '@nestjs/common';
import { IAttributesRepository } from '../interfaces/attributes-repository.interface';
import { ProductAttributeEntity } from '../entities/attribute.entity';
import { CreateAttributeDto } from '../dto/create-attribute.dto';
import { UpdateAttributeDto } from '../dto/update-attribute.dto';

/**
 * NOTE: 'ProductAttribute' model does not exist in the Prisma schema yet.
 * This is a stub repository using in-memory storage until the schema is updated.
 */
@Injectable()
export class AttributesRepository implements IAttributesRepository {
  private attributes: ProductAttributeEntity[] = [];
  private idCounter = 1;

  private makeId(): string {
    return `attr-${this.idCounter++}-${Date.now()}`;
  }

  async create(data: CreateAttributeDto, userId: string): Promise<ProductAttributeEntity> {
    const now = new Date();
    const attribute = new ProductAttributeEntity({
      id: this.makeId(),
      name: data.name,
      status: (data as any).status ?? 'ACTIVE',
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      createdBy: userId,
      updatedBy: userId,
    });
    this.attributes.push(attribute);
    return attribute;
  }

  async findMany(): Promise<ProductAttributeEntity[]> {
    return this.attributes.filter((a) => !a.deletedAt);
  }

  async findById(id: string): Promise<ProductAttributeEntity | null> {
    return this.attributes.find((a) => a.id === id && !a.deletedAt) || null;
  }

  async findByName(name: string): Promise<ProductAttributeEntity | null> {
    return this.attributes.find((a) => a.name === name && !a.deletedAt) || null;
  }

  async update(id: string, data: UpdateAttributeDto, userId: string): Promise<ProductAttributeEntity> {
    const attribute = this.attributes.find((a) => a.id === id);
    if (!attribute) throw new Error(`Attribute not found: ${id}`);
    if (data.name !== undefined) attribute.name = data.name;
    if ((data as any).status !== undefined) attribute.status = (data as any).status;
    attribute.updatedBy = userId;
    attribute.updatedAt = new Date();
    return attribute;
  }

  async softDelete(id: string, userId: string): Promise<ProductAttributeEntity> {
    const attribute = this.attributes.find((a) => a.id === id);
    if (!attribute) throw new Error(`Attribute not found: ${id}`);
    attribute.deletedAt = new Date();
    attribute.status = 'INACTIVE';
    attribute.updatedBy = userId;
    attribute.updatedAt = new Date();
    return attribute;
  }
}
