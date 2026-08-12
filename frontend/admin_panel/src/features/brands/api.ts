import { client } from '@/services/api/client';

export interface Brand {
  id: string;
  name: string;
  description?: string;
  status: string;
  createdByVendorId?: string;
  approvedByAdminId?: string;
  rejectedReason?: string;
  createdAt: string;
  updatedAt: string;
}

export const getPendingBrands = async (): Promise<Brand[]> => {
  const response = await client.get('/admin/brands/pending');
  return response.data.data;
};

export const approveBrand = async (id: string): Promise<Brand> => {
  const response = await client.put(`/admin/brands/${id}/approve`);
  return response.data.data;
};

export const rejectBrand = async ({ id, reason }: { id: string; reason: string }): Promise<Brand> => {
  const response = await client.put(`/admin/brands/${id}/reject`, { reason });
  return response.data.data;
};
