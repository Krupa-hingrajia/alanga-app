import { client } from '@/services/api/client';

export interface OrderItemProductImage {
  id?: string;
  imageUrl: string;
  isPrimary?: boolean;
  isThumbnail?: boolean;
}

export interface OrderItemProduct {
  id: string;
  name: string;
  vendorId?: string;
  image?: string | null;
  productImages?: OrderItemProductImage[];
}

export interface OrderItemProductVariant {
  id: string;
  sku: string;
  variantName: string;
  price: number;
  color?: string | null;
  size?: string | null;
  storage?: string | null;
  attributes?: Record<string, any>;
}

export interface OrderItem {
  id: string;
  orderId: string;
  vendorId: string;
  productId: string;
  productVariantId?: string;
  productNameSnapshot: string;
  variantNameSnapshot?: string | null;
  sku: string;
  quantity: number;
  unitPrice: number;
  shippingCharge: number;
  totalPrice: number;
  status: string;
  product?: OrderItemProduct;
  productVariant?: OrderItemProductVariant;
}

export interface ShippingAddressSnapshot {
  id?: string;
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

export interface OrderCustomer {
  id: string;
  fullName: string;
  email: string;
  phoneNumber?: string | null;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerId: string;
  customer?: OrderCustomer;
  addressId?: string | null;
  address?: ShippingAddressSnapshot | null;
  shippingAddressSnapshot: ShippingAddressSnapshot;
  subtotal: number;
  shippingCharge: number;
  totalAmount: number;
  grandTotal?: number;
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
  startDate?: string;
  endDate?: string;
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
  const cleanParams: Record<string, any> = {};
  if (params?.status && params.status !== 'ALL') cleanParams.status = params.status;
  if (params?.vendorId && params.vendorId !== 'ALL') cleanParams.vendorId = params.vendorId;
  if (params?.customerId && params.customerId !== 'ALL') cleanParams.customerId = params.customerId;
  if (params?.startDate) cleanParams.startDate = params.startDate;
  if (params?.endDate) cleanParams.endDate = params.endDate;
  if (params?.page) cleanParams.page = params.page;
  if (params?.limit) cleanParams.limit = params.limit;

  const response = await client.get('/admin/orders', { params: cleanParams });
  const raw = response.data;
  return {
    items: raw.data || [],
    total: raw.meta?.total || 0,
    page: raw.meta?.page || 1,
    limit: raw.meta?.limit || 10,
    totalPages: Math.ceil((raw.meta?.total || 0) / (raw.meta?.limit || 10)),
  };
};

export const getAllAdminOrders = async (params?: Omit<GetOrdersParams, 'page' | 'limit'>): Promise<Order[]> => {
  const cleanParams: Record<string, any> = { page: 1, limit: 1000 };
  if (params?.status && params.status !== 'ALL') cleanParams.status = params.status;
  if (params?.vendorId && params.vendorId !== 'ALL') cleanParams.vendorId = params.vendorId;
  if (params?.customerId && params.customerId !== 'ALL') cleanParams.customerId = params.customerId;
  if (params?.startDate) cleanParams.startDate = params.startDate;
  if (params?.endDate) cleanParams.endDate = params.endDate;

  const response = await client.get('/admin/orders', { params: cleanParams });
  return response.data?.data || [];
};

export const getAdminOrderById = async (id: string): Promise<Order> => {
  const response = await client.get(`/admin/orders/${id}`);
  return response.data.data;
};

export const updateAdminOrderStatus = async (id: string, status: string): Promise<Order> => {
  const response = await client.put(`/admin/orders/${id}/status`, { status });
  return response.data.data;
};
