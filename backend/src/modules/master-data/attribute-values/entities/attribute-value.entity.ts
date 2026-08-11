import { AttributeValue } from '@prisma/client';

export class AttributeValueEntity implements AttributeValue {
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
