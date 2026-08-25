import { client } from '@/services/api/client';

export interface Category {
  id: string;
  name: string;
  description?: string;
  image?: string;
  sortOrder?: number;
  status: string;
  createdByVendorId?: string;
  approvedByAdminId?: string;
  approvedAt?: string;
  rejectedReason?: string;
  createdAt: string;
  updatedAt: string;
  productsCount?: number;
  subCategoriesCount?: number;
  _count?: {
    products?: number;
    subCategories?: number;
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

export interface CategoryFilterParams {
  status?: string;
  vendorId?: string;
  search?: string;
  page?: number;
  limit?: number;
}

export interface CategoryListResponse {
  items: Category[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export const getAdminCategories = async (params?: CategoryFilterParams): Promise<CategoryListResponse> => {
  const response = await client.get('/admin/categories', { params });
  return response.data.data;
};

export const createAdminCategory = async (data: { name: string; description?: string; image?: string; status?: string }): Promise<Category> => {
  const response = await client.post('/admin/categories', { status: 'ACTIVE', ...data });
  return response.data.data;
};

export const updateAdminCategory = async ({ id, data }: { id: string; data: { name?: string; description?: string; image?: string; status?: string } }): Promise<Category> => {
  const response = await client.put(`/admin/categories/${id}`, data);
  return response.data.data;
};

export const toggleCategoryStatus = async (id: string, currentStatus: string): Promise<Category> => {
  const nextStatus = currentStatus.toUpperCase() === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
  const response = await client.put(`/admin/categories/${id}`, { status: nextStatus, isActive: nextStatus === 'ACTIVE' });
  return response.data.data;
};

export const bulkUpdateCategoryStatus = async (ids: string[], status: 'ACTIVE' | 'INACTIVE'): Promise<void> => {
  await Promise.all(
    ids.map((id) => client.put(`/admin/categories/${id}`, { status, isActive: status === 'ACTIVE' }))
  );
};

export const deleteAdminCategory = async (id: string): Promise<void> => {
  await client.delete(`/admin/categories/${id}`);
};

export const bulkDeleteCategories = async (ids: string[]): Promise<void> => {
  await Promise.all(ids.map((id) => client.delete(`/admin/categories/${id}`)));
};
