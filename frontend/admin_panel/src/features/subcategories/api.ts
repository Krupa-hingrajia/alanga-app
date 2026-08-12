import { client } from '@/services/api/client';

export interface SubCategory {
  id: string;
  name: string;
  description?: string;
  status: string;
  categoryId?: string;
  createdByVendorId?: string;
  rejectedReason?: string;
  createdAt: string;
  updatedAt: string;
}

export const getPendingSubCategories = async (): Promise<SubCategory[]> => {
  const response = await client.get('/admin/sub-categories/pending');
  return response.data.data;
};

export const approveSubCategory = async (id: string): Promise<SubCategory> => {
  const response = await client.put(`/admin/sub-categories/${id}/approve`);
  return response.data.data;
};

export const rejectSubCategory = async ({ id, reason }: { id: string; reason: string }): Promise<SubCategory> => {
  const response = await client.put(`/admin/sub-categories/${id}/reject`, { reason });
  return response.data.data;
};
