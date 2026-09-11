import { client } from '@/services/api/client';

export interface OrderItem {
  id: string;
  orderId: string;
  vendorId: string;
  productId: string;
  productVariantId: string;
  productNameSnapshot: string;
  variantNameSnapshot?: string | null;
  sku: string;
  quantity: number;
  unitPrice: number;
  shippingCharge: number;
  totalPrice: number;
  status: string;
}

export interface ShippingAddressSnapshot {
  fullName: string;
  mobileNumber: string;
  alternateMobile?: string | null;
  addressLine1: string;
  addressLine2?: string | null;
  landmark?: string | null;
  city: string;
  state: string;
  country?: string;
  postalCode: string;
  addressType?: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerId: string;
  customer?: {
    id: string;
    fullName: string;
    email: string;
    phoneNumber?: string | null;
  };
  shippingAddressSnapshot: ShippingAddressSnapshot;
  subtotal: number;
  shippingCharge: number;
  totalAmount: number;
  paymentMethod: string;
  paymentStatus: string;
  status: string;
  notes?: string | null;
  createdAt: string;
  updatedAt: string;
  orderItems?: OrderItem[];
}

export interface GetOrdersParams {
  search?: string;
  status?: string;
  vendorId?: string;
  customerId?: string;
  page?: number;
  limit?: number;
}

export interface OrdersResponse {
  items: Order[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export const getAdminOrders = async (params?: GetOrdersParams): Promise<OrdersResponse> => {
  const response = await client.get('/admin/orders', { params });
  const raw = response.data;
  return {
    items: raw.data || [],
    total: raw.meta?.total || 0,
    page: raw.meta?.page || 1,
    limit: raw.meta?.limit || 10,
    totalPages: Math.ceil((raw.meta?.total || 0) / (raw.meta?.limit || 10)),
  };
};

export const getAdminOrderById = async (id: string): Promise<Order> => {
  const response = await client.get(`/admin/orders/${id}`);
  return response.data.data;
};

export const updateAdminOrderStatus = async (id: string, status: string): Promise<Order> => {
  const response = await client.put(`/admin/orders/${id}/status`, { status });
  return response.data.data;
};
