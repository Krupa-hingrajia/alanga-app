import { Injectable } from '@nestjs/common';
import { IUnitsRepository } from '../interfaces/units-repository.interface';
import { UnitEntity } from '../entities/unit.entity';
import { CreateUnitDto } from '../dto/create-unit.dto';
import { UpdateUnitDto } from '../dto/update-unit.dto';

/**
 * NOTE: 'Unit' model does not exist in the Prisma schema yet.
 * This is a stub repository using in-memory storage until the schema is updated.
 */
@Injectable()
export class UnitsRepository implements IUnitsRepository {
  private units: UnitEntity[] = [];
  private idCounter = 1;

  private makeId(): string {
    return `unit-${this.idCounter++}-${Date.now()}`;
  }

  async create(data: CreateUnitDto, userId: string): Promise<UnitEntity> {
    const now = new Date();
    const unit = new UnitEntity({
      id: this.makeId(),
      name: data.name,
      symbol: (data as any).symbol || (data as any).shortName || '',
      status: (data as any).status ?? 'ACTIVE',
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      createdBy: userId,
      updatedBy: userId,
    });
    this.units.push(unit);
    return unit;
  }

  async findMany(): Promise<UnitEntity[]> {
    return this.units.filter((u) => !u.deletedAt);
  }

  async findById(id: string): Promise<UnitEntity | null> {
    return this.units.find((u) => u.id === id && !u.deletedAt) || null;
  }

  async findByName(name: string): Promise<UnitEntity | null> {
    return this.units.find((u) => u.name === name && !u.deletedAt) || null;
  }

  async update(id: string, data: UpdateUnitDto, userId: string): Promise<UnitEntity> {
    const unit = this.units.find((u) => u.id === id);
    if (!unit) throw new Error(`Unit not found: ${id}`);
    if (data.name !== undefined) unit.name = data.name;
    if ((data as any).symbol !== undefined) unit.symbol = (data as any).symbol;
    if ((data as any).status !== undefined) unit.status = (data as any).status;
    unit.updatedBy = userId;
    unit.updatedAt = new Date();
    return unit;
  }

  async softDelete(id: string, userId: string): Promise<UnitEntity> {
    const unit = this.units.find((u) => u.id === id);
    if (!unit) throw new Error(`Unit not found: ${id}`);
    unit.deletedAt = new Date();
    unit.status = 'INACTIVE';
    unit.updatedBy = userId;
    unit.updatedAt = new Date();
    return unit;
  }
}
