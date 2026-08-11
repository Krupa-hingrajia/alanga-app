import { Brand } from '@prisma/client';

export class BrandEntity implements Brand {
  id: string;
  name: string;
  logo: string | null;
  description: string | null;
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

  constructor(partial: Partial<BrandEntity>) {
    Object.assign(this, partial);
  }
}
