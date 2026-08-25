import { client } from '@/services/api/client';

export interface SubCategory {
  id: string;
  name: string;
  description?: string;
  image?: string;
  sortOrder?: number;
  status: string;
  categoryId?: string;
  category?: {
    id: string;
    name: string;
  };
  createdByVendorId?: string;
  approvedByAdminId?: string;
  approvedAt?: string;
  rejectedReason?: string;
  createdAt: string;
  updatedAt: string;
  productsCount?: number;
  _count?: {
    products?: number;
  };
  vendorId?: string;
  vendorName?: string;
  vendorEmail?: string;
  vendor?: {
    id: string;
    name: string;
    email: string;
  };
}

export interface SubCategoryFilterParams {
  status?: string;
  vendorId?: string;
  categoryId?: string;
  search?: string;
  page?: number;
  limit?: number;
}

export interface SubCategoryListResponse {
  items: SubCategory[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export const getAdminSubCategories = async (params?: SubCategoryFilterParams): Promise<SubCategoryListResponse> => {
  const response = await client.get('/admin/subcategories', { params });
  return response.data.data;
};

export const createAdminSubCategory = async (data: { categoryId: string; name: string; description?: string; image?: string; status?: string }): Promise<SubCategory> => {
  const response = await client.post('/admin/sub-categories', { status: 'ACTIVE', ...data });
  return response.data.data;
};

export const updateAdminSubCategory = async ({ id, data }: { id: string; data: { categoryId?: string; name?: string; description?: string; image?: string; status?: string } }): Promise<SubCategory> => {
  const response = await client.put(`/admin/sub-categories/${id}`, data);
  return response.data.data;
};

export const toggleSubCategoryStatus = async (id: string, currentStatus: string): Promise<SubCategory> => {
  const nextStatus = currentStatus.toUpperCase() === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
  const response = await client.put(`/admin/sub-categories/${id}`, { status: nextStatus, isActive: nextStatus === 'ACTIVE' });
  return response.data.data;
};

export const bulkUpdateSubCategoryStatus = async (ids: string[], status: 'ACTIVE' | 'INACTIVE'): Promise<void> => {
  await Promise.all(
    ids.map((id) => client.put(`/admin/sub-categories/${id}`, { status, isActive: status === 'ACTIVE' }))
  );
};

export const deleteAdminSubCategory = async (id: string): Promise<void> => {
  await client.delete(`/admin/sub-categories/${id}`);
};

export const bulkDeleteSubCategories = async (ids: string[]): Promise<void> => {
  await Promise.all(ids.map((id) => client.delete(`/admin/sub-categories/${id}`)));
};
