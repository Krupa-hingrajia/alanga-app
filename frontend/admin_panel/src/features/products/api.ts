import { client } from '@/services/api/client';

export interface Product {
  id: string;
  sku: string;
  name: string;
  description?: string;
  mrp: number;
  sellingPrice: number;
  status: string;
  categoryId?: string;
  brandId?: string;
  createdByVendorId?: string;
  rejectedReason?: string;
  createdAt: string;
  updatedAt: string;
}

export const getPendingProducts = async (): Promise<Product[]> => {
  const response = await client.get('/admin/products/pending');
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
