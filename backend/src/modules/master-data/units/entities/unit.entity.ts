import { Unit } from '@prisma/client';

export class UnitEntity implements Unit {
  id: string;
  name: string;
  shortName: string;
  status: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
  createdBy: string | null;
  updatedBy: string | null;

  constructor(partial: Partial<UnitEntity>) {
    Object.assign(this, partial);
  }
}
