import { client } from '@/services/api/client';

export interface Vendor {
  id: string;
  fullName: string;
  email: string;
  countryCode: string;
  mobileNumber: string;
  role: string;
  status: string;
  businessName?: string;
  businessType?: string;
  city?: string;
  state?: string;
  pincode?: string;
  gstNumber?: string;
  panNumber?: string;
  createdAt: string;
  updatedAt: string;
}

export interface VendorListResponse {
  items: Vendor[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export const getVendors = async (params: {
  status?: string;
  search?: string;
  page?: number;
  limit?: number;
}): Promise<VendorListResponse> => {
  const response = await client.get('/admin/vendors', { params });
  return response.data.data;
};

export const getVendorById = async (id: string): Promise<Vendor> => {
  const response = await client.get(`/admin/vendors/${id}`);
  return response.data.data;
};

export const approveVendor = async (id: string): Promise<Vendor> => {
  const response = await client.put(`/admin/vendors/${id}/approve`);
  return response.data.data;
};

export const rejectVendor = async (id: string): Promise<Vendor> => {
  const response = await client.put(`/admin/vendors/${id}/reject`);
  return response.data.data;
};

export const suspendVendor = async (id: string): Promise<Vendor> => {
  const response = await client.put(`/admin/vendors/${id}/suspend`);
  return response.data.data;
};
