import { Injectable } from '@nestjs/common';
import { IVendorDashboardRepository } from '../interfaces/vendor-dashboard-repository.interface';

@Injectable()
export class VendorDashboardService {
  constructor(
    private readonly dashboardRepository: IVendorDashboardRepository,
  ) {}

  async getSummary(vendorId: string) {
    const [productsCount, ordersCountAndRev, kycInfo] = await Promise.all([
      this.dashboardRepository.getProductsCount(vendorId),
      this.dashboardRepository.getOrdersCountAndRevenue(vendorId),
      this.dashboardRepository.getVendorKycStatus(vendorId),
    ]);

    return {
      totalProducts: productsCount.total,
      activeProducts: productsCount.active,
      outOfStockProducts: productsCount.outOfStock,
      lowStockProducts: productsCount.lowStock,
      totalOrders: ordersCountAndRev.totalOrders,
      pendingOrders: ordersCountAndRev.pendingOrders,
      ordersToDispatch: ordersCountAndRev.ordersToDispatch,
      completedOrders: ordersCountAndRev.completedOrders,
      totalRevenue: ordersCountAndRev.totalRevenue,
      currentMonthRevenue: ordersCountAndRev.currentMonthRevenue,
      todayRevenue: ordersCountAndRev.todayRevenue,
      todayOrders: ordersCountAndRev.todayOrders,
      kycStatus: kycInfo.kycStatus,
      hasProfile: kycInfo.hasProfile,
      storeName: kycInfo.storeName,
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
