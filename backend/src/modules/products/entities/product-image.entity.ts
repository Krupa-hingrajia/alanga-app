import { ProductImage } from '@prisma/client';

export class ProductImageEntity implements ProductImage {
  id: string;
  productId: string;
  productVariantId: string | null;
  imageUrl: string;
  isPrimary: boolean;
  displayOrder: number;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;

  constructor(partial: Partial<ProductImageEntity>) {
    Object.assign(this, partial);
  }
}
