import { client } from '@/services/api/client';

export interface Customer {
  id: string;
  fullName: string;
  email: string;
  phoneNumber?: string | null;
  role: string;
  status: string;
  kycStatus?: string;
  profileImage?: string | null;
  createdAt: string;
  updatedAt: string;
  _count?: {
    orders?: number;
  };
}

export interface GetCustomersParams {
  search?: string;
  status?: string;
  page?: number;
  limit?: number;
}

export interface CustomersResponse {
  items: Customer[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export const getCustomers = async (params?: GetCustomersParams): Promise<CustomersResponse> => {
  const response = await client.get('/admin/customers', { params });
  return response.data.data;
};

export const getCustomerById = async (id: string): Promise<Customer> => {
  const response = await client.get(`/admin/customers/${id}`);
  return response.data.data;
};

export const updateCustomerStatus = async (id: string, status: string): Promise<Customer> => {
  const response = await client.put(`/admin/customers/${id}/status`, { status });
  return response.data.data;
};

export const suspendCustomer = async (id: string): Promise<Customer> => {
  const response = await client.put(`/admin/customers/${id}/suspend`);
  return response.data.data;
};

export const activateCustomer = async (id: string): Promise<Customer> => {
  const response = await client.put(`/admin/customers/${id}/activate`);
  return response.data.data;
};
