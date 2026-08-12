export abstract class IAdminDashboardRepository {
  abstract getSummary(): Promise<{
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
  }>;
}
