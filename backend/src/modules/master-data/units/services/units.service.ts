import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { IUnitsRepository } from '../interfaces/units-repository.interface';
import { CreateUnitDto } from '../dto/create-unit.dto';
import { UpdateUnitDto } from '../dto/update-unit.dto';

@Injectable()
export class UnitsService {
  constructor(private readonly unitsRepository: IUnitsRepository) {}

  async create(data: CreateUnitDto, userId: string) {
    const existing = await this.unitsRepository.findByName(data.name);
    if (existing) {
      throw new ConflictException(`Unit with name "${data.name}" already exists.`);
    }
    return this.unitsRepository.create(data, userId);
  }

  async findAll() {
    return this.unitsRepository.findMany();
  }

  async findOne(id: string) {
    const unit = await this.unitsRepository.findById(id);
    if (!unit) {
      throw new NotFoundException(`Unit with ID "${id}" not found.`);
    }
    return unit;
  }

  async update(id: string, data: UpdateUnitDto, userId: string) {
    await this.findOne(id);

    if (data.name) {
      const existing = await this.unitsRepository.findByName(data.name);
      if (existing && existing.id !== id) {
        throw new ConflictException(`Unit with name "${data.name}" already exists.`);
      }
    }

    return this.unitsRepository.update(id, data, userId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.unitsRepository.softDelete(id, userId);
  }
}
