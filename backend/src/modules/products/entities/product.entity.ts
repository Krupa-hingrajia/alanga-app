import { Product } from '@prisma/client';

export class ProductEntity implements Product {
  id: string;
  name: string;
  description: string | null;
  price: number;
  stock: number;
  isActive: boolean;
  vendorId: string;
  status: string;
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
