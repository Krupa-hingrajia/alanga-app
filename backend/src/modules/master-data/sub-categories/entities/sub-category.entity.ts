import { SubCategory } from '@prisma/client';

export class SubCategoryEntity implements SubCategory {
  id: string;
  categoryId: string;
  name: string;
  slug: string;
  description: string | null;
  image: string | null;
  isActive: boolean;
  displayOrder: number;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;

  constructor(partial: Partial<SubCategoryEntity>) {
    Object.assign(this, partial);
  }
}
