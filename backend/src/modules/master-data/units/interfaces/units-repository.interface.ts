import { UnitEntity } from '../entities/unit.entity';
import { CreateUnitDto } from '../dto/create-unit.dto';
import { UpdateUnitDto } from '../dto/update-unit.dto';

export abstract class IUnitsRepository {
  abstract create(data: CreateUnitDto, userId: string): Promise<UnitEntity>;
  abstract findMany(): Promise<UnitEntity[]>;
  abstract findById(id: string): Promise<UnitEntity | null>;
  abstract findByName(name: string): Promise<UnitEntity | null>;
  abstract update(id: string, data: UpdateUnitDto, userId: string): Promise<UnitEntity>;
  abstract softDelete(id: string, userId: string): Promise<UnitEntity>;
}
