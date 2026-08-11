export abstract class IVendorDashboardRepository {
  abstract getProductsCount(vendorId: string): Promise<{
    total: number;
    active: number;
    outOfStock: number;
  }>;

  abstract getOrdersCountAndRevenue(vendorId: string): Promise<{
    totalOrders: number;
    pendingOrders: number;
    completedOrders: number;
    totalRevenue: number;
    currentMonthRevenue: number;
  }>;

  abstract getSalesOverview(
    vendorId: string,
    startDate?: Date,
    endDate?: Date,
  ): Promise<{
    dailySales: Array<{ date: string; amount: number; count: number }>;
    weeklySales: Array<{ week: string; amount: number; count: number }>;
    monthlySales: Array<{ month: string; amount: number; count: number }>;
  }>;

  abstract getRecentOrders(
    vendorId: string,
    limit: number,
    offset: number,
  ): Promise<
    Array<{
      orderNumber: string;
      customerName: string;
      orderStatus: string;
      amount: number;
      createdAt: Date;
    }>
  >;

  abstract getLowStockProducts(
    vendorId: string,
    threshold: number,
  ): Promise<
    Array<{
      id: string;
      name: string;
      price: number;
      stock: number;
      isActive: boolean;
    }>
  >;
}
