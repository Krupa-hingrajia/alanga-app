import { client } from '@/services/api/client';

export interface Product {
  id: string;
  sku: string;
  name: string;
  description?: string;
  shortDescription?: string;
  mrp: number;
  sellingPrice: number;
  taxPercentage?: number;
  stock?: number;
  status: string;
  image?: string;
  categoryId?: string;
  subCategoryId?: string;
  brandId?: string;
  category?: { id: string; name: string };
  subCategory?: { id: string; name: string };
  brand?: { id: string; name: string; logo?: string };
  vendorId?: string;
  createdByVendorId?: string;
  approvedByAdminId?: string;
  approvedAt?: string;
  rejectedReason?: string;
  createdAt: string;
  updatedAt: string;
  vendorName?: string;
  vendorEmail?: string;
  vendor?: {
    id: string;
    name: string;
    email: string;
  };
}

export interface ProductFilterParams {
  status?: string;
  vendorId?: string;
  categoryId?: string;
  subCategoryId?: string;
  brandId?: string;
  search?: string;
  sort?: string;
  page?: number;
  limit?: number;
}

export interface ProductListResponse {
  items: Product[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export const getPendingProducts = async (): Promise<Product[]> => {
  const response = await client.get('/admin/products/pending');
  return response.data.data;
};

export const getAdminProducts = async (params?: ProductFilterParams): Promise<ProductListResponse> => {
  const response = await client.get('/admin/products', { params });
  return response.data.data;
};

export const approveProduct = async (id: string): Promise<Product> => {
  const response = await client.put(`/admin/products/${id}/approve`);
  return response.data.data;
};

export const rejectProduct = async ({ id, reason }: { id: string; reason: string }): Promise<Product> => {
  const response = await client.put(`/admin/products/${id}/reject`, { reason });
  return response.data.data;
};

export const suspendProduct = async (id: string): Promise<Product> => {
  const response = await client.put(`/admin/products/${id}/suspend`);
  return response.data.data;
};
