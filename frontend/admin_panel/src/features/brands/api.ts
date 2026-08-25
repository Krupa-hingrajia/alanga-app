import { client } from '@/services/api/client';

export interface Brand {
  id: string;
  name: string;
  logo?: string;
  description?: string;
  status: string;
  isActive?: boolean;
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

export interface BrandFilterParams {
  status?: string;
  vendorId?: string;
  search?: string;
  page?: number;
  limit?: number;
}

export interface BrandListResponse {
  items: Brand[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export const getPendingBrands = async (): Promise<Brand[]> => {
  const response = await client.get('/admin/brands/pending');
  return response.data.data;
};

export const getAdminBrands = async (params?: BrandFilterParams): Promise<BrandListResponse> => {
  const response = await client.get('/admin/brands', { params });
  return response.data.data;
};

export const createAdminBrand = async (data: { name: string; description?: string; logo?: string; status?: string }): Promise<Brand> => {
  const response = await client.post('/admin/brands', { status: 'ACTIVE', ...data });
  return response.data.data;
};

export const updateAdminBrand = async ({ id, data }: { id: string; data: { name?: string; description?: string; logo?: string; status?: string } }): Promise<Brand> => {
  const response = await client.put(`/admin/brands/${id}`, data);
  return response.data.data;
};

export const toggleBrandStatus = async (id: string, currentStatus: string): Promise<Brand> => {
  const nextStatus = currentStatus.toUpperCase() === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
  const response = await client.put(`/admin/brands/${id}`, { status: nextStatus, isActive: nextStatus === 'ACTIVE' });
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

export const deleteAdminBrand = async (id: string): Promise<void> => {
  await client.delete(`/admin/brands/${id}`);
};
