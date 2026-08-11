import { Injectable } from '@nestjs/common';
import { IUnitsRepository } from '../interfaces/units-repository.interface';
import { PrismaService } from '../../../../database/prisma.service';
import { UnitEntity } from '../entities/unit.entity';
import { CreateUnitDto } from '../dto/create-unit.dto';
import { UpdateUnitDto } from '../dto/update-unit.dto';

@Injectable()
export class UnitsRepository implements IUnitsRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(unit: any): UnitEntity {
    return new UnitEntity({
      id: unit.id,
      name: unit.name,
      shortName: unit.shortName,
      status: unit.status,
      createdAt: unit.createdAt,
      updatedAt: unit.updatedAt,
      deletedAt: unit.deletedAt,
      createdBy: unit.createdBy,
      updatedBy: unit.updatedBy,
    });
  }

  async create(data: CreateUnitDto, userId: string): Promise<UnitEntity> {
    const unit = await this.prisma.unit.create({
      data: {
        name: data.name,
        shortName: data.shortName,
        status: data.status ?? 'ACTIVE',
        createdBy: userId,
      },
    });
    return this.mapToEntity(unit);
  }

  async findMany(): Promise<UnitEntity[]> {
    const units = await this.prisma.unit.findMany({
      where: { deletedAt: null },
      orderBy: { name: 'asc' },
    });
    return units.map((u) => this.mapToEntity(u));
  }

  async findById(id: string): Promise<UnitEntity | null> {
    const unit = await this.prisma.unit.findFirst({
      where: { id, deletedAt: null },
    });
    return unit ? this.mapToEntity(unit) : null;
  }

  async findByName(name: string): Promise<UnitEntity | null> {
    const unit = await this.prisma.unit.findFirst({
      where: { name, deletedAt: null },
    });
    return unit ? this.mapToEntity(unit) : null;
  }

  async update(id: string, data: UpdateUnitDto, userId: string): Promise<UnitEntity> {
    const unit = await this.prisma.unit.update({
      where: { id },
      data: {
        name: data.name,
        shortName: data.shortName,
        status: data.status,
        updatedBy: userId,
      },
    });
    return this.mapToEntity(unit);
  }

  async softDelete(id: string, userId: string): Promise<UnitEntity> {
    const unit = await this.prisma.unit.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: 'INACTIVE',
        updatedBy: userId,
      },
    });
    return this.mapToEntity(unit);
  }
}
