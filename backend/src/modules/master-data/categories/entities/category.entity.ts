import { Category } from '@prisma/client';

export class CategoryEntity implements Category {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  image: string | null;
  isActive: boolean;
  displayOrder: number;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;

  constructor(partial: Partial<CategoryEntity>) {
    Object.assign(this, partial);
  }
}
