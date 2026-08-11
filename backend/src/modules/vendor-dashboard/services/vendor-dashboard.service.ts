import { Injectable } from '@nestjs/common';
import { IVendorDashboardRepository } from '../interfaces/vendor-dashboard-repository.interface';

@Injectable()
export class VendorDashboardService {
  constructor(
    private readonly dashboardRepository: IVendorDashboardRepository,
  ) {}

  async getSummary(vendorId: string) {
    const [productsCount, ordersCountAndRev] = await Promise.all([
      this.dashboardRepository.getProductsCount(vendorId),
      this.dashboardRepository.getOrdersCountAndRevenue(vendorId),
    ]);

    return {
      totalProducts: productsCount.total,
      activeProducts: productsCount.active,
      outOfStockProducts: productsCount.outOfStock,
      totalOrders: ordersCountAndRev.totalOrders,
      pendingOrders: ordersCountAndRev.pendingOrders,
      completedOrders: ordersCountAndRev.completedOrders,
      totalRevenue: ordersCountAndRev.totalRevenue,
      currentMonthRevenue: ordersCountAndRev.currentMonthRevenue,
    };
  }

  async getSalesOverview(vendorId: string, startDateStr?: string, endDateStr?: string) {
    const startDate = startDateStr ? new Date(startDateStr) : undefined;
    const endDate = endDateStr ? new Date(endDateStr) : undefined;

    return this.dashboardRepository.getSalesOverview(vendorId, startDate, endDate);
  }

  async getRecentOrders(vendorId: string, limit: number, offset: number) {
    return this.dashboardRepository.getRecentOrders(vendorId, limit, offset);
  }

  async getLowStockProducts(vendorId: string, threshold: number) {
    return this.dashboardRepository.getLowStockProducts(vendorId, threshold);
  }
}
