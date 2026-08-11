import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { IAttributeValuesRepository } from '../interfaces/attribute-values-repository.interface';
import { AttributesService } from '../../attributes/services/attributes.service';
import { CreateAttributeValueDto } from '../dto/create-attribute-value.dto';
import { UpdateAttributeValueDto } from '../dto/update-attribute-value.dto';

@Injectable()
export class AttributeValuesService {
  constructor(
    private readonly attributeValuesRepository: IAttributeValuesRepository,
    private readonly attributesService: AttributesService,
  ) {}

  async create(data: CreateAttributeValueDto, userId: string) {
    await this.attributesService.findOne(data.attributeId);

    const existing = await this.attributeValuesRepository.findByValueAndAttribute(data.value, data.attributeId);
    if (existing) {
      throw new ConflictException(`Attribute value "${data.value}" already exists for this attribute.`);
    }

    return this.attributeValuesRepository.create(data, userId);
  }

  async findAll(attributeId?: string) {
    if (attributeId) {
      await this.attributesService.findOne(attributeId);
    }
    return this.attributeValuesRepository.findMany(attributeId);
  }

  async findOne(id: string) {
    const val = await this.attributeValuesRepository.findById(id);
    if (!val) {
      throw new NotFoundException(`Attribute value with ID "${id}" not found.`);
    }
    return val;
  }

  async update(id: string, data: UpdateAttributeValueDto, userId: string) {
    const current = await this.findOne(id);

    const targetAttributeId = data.attributeId || current.attributeId;
    const targetValue = data.value || current.value;

    if (data.attributeId && data.attributeId !== current.attributeId) {
      await this.attributesService.findOne(data.attributeId);
    }

    if (data.value || data.attributeId) {
      const existing = await this.attributeValuesRepository.findByValueAndAttribute(targetValue, targetAttributeId);
      if (existing && existing.id !== id) {
        throw new ConflictException(`Attribute value "${targetValue}" already exists for this attribute.`);
      }
    }

    return this.attributeValuesRepository.update(id, data, userId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.attributeValuesRepository.softDelete(id, userId);
  }
}
