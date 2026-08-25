export class AttributeValueEntity {
  id: string;
  attributeId: string;
  value: string;
  sortOrder: number;
  status: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
  createdBy: string | null;
  updatedBy: string | null;

  constructor(partial: Partial<AttributeValueEntity>) {
    Object.assign(this, partial);
  }
}
