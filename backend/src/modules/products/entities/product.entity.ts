import { Product } from '@prisma/client';

export class ProductEntity implements Product {
  id: string;
  name: string;
  description: string | null;
  shortDescription: string | null;
  categoryId: string;
  subCategoryId: string;
  brandId: string;
  sellingPrice: number;
  mrp: number;
  taxPercentage: number;
  stock: number;
  weight: number | null;
  length: number | null;
  width: number | null;
  height: number | null;
  sku: string;
  status: string;
  vendorId: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
  createdBy: string | null;
  updatedBy: string | null;
  createdByVendorId: string | null;
  approvedByAdminId: string | null;
  approvedAt: Date | null;
  rejectedReason: string | null;

  constructor(partial: Partial<ProductEntity>) {
    Object.assign(this, partial);
  }
}
