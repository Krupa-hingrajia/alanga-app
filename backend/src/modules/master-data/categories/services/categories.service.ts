import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { ICategoriesRepository } from '../interfaces/categories-repository.interface';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

@Injectable()
export class CategoriesService {
  constructor(private readonly categoriesRepository: ICategoriesRepository) {}

  async create(data: CreateCategoryDto, userId: string) {
    const existing = await this.categoriesRepository.findByName(data.name);
    if (existing) {
      throw new ConflictException(`Category with name "${data.name}" already exists.`);
    }
    return this.categoriesRepository.create(data, userId);
  }

  async findAll() {
    return this.categoriesRepository.findMany();
  }

  async findOne(id: string) {
    const category = await this.categoriesRepository.findById(id);
    if (!category) {
      throw new NotFoundException(`Category with ID "${id}" not found.`);
    }
    return category;
  }

  async update(id: string, data: UpdateCategoryDto, userId: string) {
    await this.findOne(id);

    if (data.name) {
      const existing = await this.categoriesRepository.findByName(data.name);
      if (existing && existing.id !== id) {
        throw new ConflictException(`Category with name "${data.name}" already exists.`);
      }
    }

    return this.categoriesRepository.update(id, data, userId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.categoriesRepository.softDelete(id, userId);
  }
}
