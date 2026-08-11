import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { IBrandsRepository } from '../interfaces/brands-repository.interface';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { UpdateBrandDto } from '../dto/update-brand.dto';

@Injectable()
export class BrandsService {
  constructor(private readonly brandsRepository: IBrandsRepository) {}

  async create(data: CreateBrandDto, userId: string) {
    const existing = await this.brandsRepository.findByName(data.name);
    if (existing) {
      throw new ConflictException(`Brand with name "${data.name}" already exists.`);
    }
    return this.brandsRepository.create(data, userId);
  }

  async findAll() {
    return this.brandsRepository.findMany();
  }

  async findOne(id: string) {
    const brand = await this.brandsRepository.findById(id);
    if (!brand) {
      throw new NotFoundException(`Brand with ID "${id}" not found.`);
    }
    return brand;
  }

  async update(id: string, data: UpdateBrandDto, userId: string) {
    await this.findOne(id);

    if (data.name) {
      const existing = await this.brandsRepository.findByName(data.name);
      if (existing && existing.id !== id) {
        throw new ConflictException(`Brand with name "${data.name}" already exists.`);
      }
    }

    return this.brandsRepository.update(id, data, userId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.brandsRepository.softDelete(id, userId);
  }
}
