import { ProductVariant } from '@prisma/client';

export class ProductVariantEntity implements ProductVariant {
  id: string;
  productId: string;
  sku: string;
  variantName: string;
  color: string | null;
  size: string | null;
  storage: string | null;
  price: number;
  mrp: number | null;
  stock: number;
  status: string;
  attributes: any;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
  images?: any[];

  constructor(partial: Partial<ProductVariantEntity>) {
    Object.assign(this, partial);
    this.images = partial.images || [];
  }
}
