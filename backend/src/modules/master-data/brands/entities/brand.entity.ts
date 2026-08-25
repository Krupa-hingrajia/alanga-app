import { Brand } from '@prisma/client';

export class BrandEntity implements Brand {
  id: string;
  name: string;
  slug: string | null;
  description: string | null;
  logo: string | null;
  website: string | null;
  status: string;
  isActive: boolean;
  displayOrder: number;
  createdByVendorId: string | null;
  approvedByAdminId: string | null;
  approvedAt: Date | null;
  rejectedReason: string | null;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;

  constructor(partial: Partial<BrandEntity>) {
    Object.assign(this, partial);
  }
}
