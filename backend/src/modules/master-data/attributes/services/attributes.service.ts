import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { IAttributesRepository } from '../interfaces/attributes-repository.interface';
import { CreateAttributeDto } from '../dto/create-attribute.dto';
import { UpdateAttributeDto } from '../dto/update-attribute.dto';

@Injectable()
export class AttributesService {
  constructor(private readonly attributesRepository: IAttributesRepository) {}

  async create(data: CreateAttributeDto, userId: string) {
    const existing = await this.attributesRepository.findByName(data.name);
    if (existing) {
      throw new ConflictException(`Attribute with name "${data.name}" already exists.`);
    }
    return this.attributesRepository.create(data, userId);
  }

  async findAll() {
    return this.attributesRepository.findMany();
  }

  async findOne(id: string) {
    const attribute = await this.attributesRepository.findById(id);
    if (!attribute) {
      throw new NotFoundException(`Attribute with ID "${id}" not found.`);
    }
    return attribute;
  }

  async update(id: string, data: UpdateAttributeDto, userId: string) {
    await this.findOne(id);

    if (data.name) {
      const existing = await this.attributesRepository.findByName(data.name);
      if (existing && existing.id !== id) {
        throw new ConflictException(`Attribute with name "${data.name}" already exists.`);
      }
    }

    return this.attributesRepository.update(id, data, userId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.attributesRepository.softDelete(id, userId);
  }
}
