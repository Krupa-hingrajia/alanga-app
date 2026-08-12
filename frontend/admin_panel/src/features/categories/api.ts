import { client } from '@/services/api/client';

export interface Category {
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

export const getPendingCategories = async (): Promise<Category[]> => {
  const response = await client.get('/admin/categories/pending');
  return response.data.data;
};

export const approveCategory = async (id: string): Promise<Category> => {
  const response = await client.put(`/admin/categories/${id}/approve`);
  return response.data.data;
};

export const rejectCategory = async ({ id, reason }: { id: string; reason: string }): Promise<Category> => {
  const response = await client.put(`/admin/categories/${id}/reject`, { reason });
  return response.data.data;
};
