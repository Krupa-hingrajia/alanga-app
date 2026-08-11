import { Category } from '@prisma/client';

export class CategoryEntity implements Category {
  id: string;
  name: string;
  description: string | null;
  image: string | null;
  sortOrder: number;
  status: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
  createdBy: string | null;
  updatedBy: string | null;

  constructor(partial: Partial<CategoryEntity>) {
    Object.assign(this, partial);
  }
}
