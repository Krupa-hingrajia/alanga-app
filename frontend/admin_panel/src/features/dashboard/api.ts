import { client } from '@/services/api/client';

export interface DashboardSummary {
  totalCustomers: number;
  totalVendors: number;
  activeVendors: number;
  pendingVendorApprovals: number;
  totalProducts: number;
  totalCategories: number;
  pendingCategories: number;
  totalBrands: number;
  pendingBrands: number;
  pendingProducts: number;
  totalCompletedOrders: number;
  totalCompletedOrdersRevenue: number;
}

export const getDashboardSummary = async (): Promise<DashboardSummary> => {
  const response = await client.get('/admin/dashboard/summary');
  return response.data.data;
};
