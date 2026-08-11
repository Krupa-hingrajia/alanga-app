import { SubCategory } from '@prisma/client';

export class SubCategoryEntity implements SubCategory {
  id: string;
  categoryId: string;
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

  constructor(partial: Partial<SubCategoryEntity>) {
    Object.assign(this, partial);
  }
}
