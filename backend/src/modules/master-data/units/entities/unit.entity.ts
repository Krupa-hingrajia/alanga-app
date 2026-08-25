export class UnitEntity {
  id: string;
  name: string;
  symbol: string;
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
