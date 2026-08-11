export abstract class IAdminDashboardRepository {
  abstract getSummary(): Promise<{
    totalCustomers: number;
    totalVendors: number;
    activeVendors: number;
    pendingVendorApprovals: number;
    totalProducts: number;
    totalCategories: number;
    totalOrders: number;
    totalRevenue: number;
  }>;
}
