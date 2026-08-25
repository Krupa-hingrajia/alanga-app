import { Injectable } from '@nestjs/common';
import { IAdminDashboardRepository } from '../interfaces/admin-dashboard-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { Role, AccountStatus } from '@prisma/client';

@Injectable()
export class AdminDashboardRepository implements IAdminDashboardRepository {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary(): Promise<{
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
  }> {
    const [
      totalCustomers,
      totalVendors,
      activeVendors,
      pendingVendorApprovals,
      totalProducts,
      pendingProducts,
      totalCategories,
      totalBrands,
    ] = await Promise.all([
      this.prisma.user.count({ where: { role: Role.CUSTOMER } }),
      this.prisma.user.count({ where: { role: Role.VENDOR } }),
      this.prisma.user.count({ where: { role: Role.VENDOR, status: AccountStatus.ACTIVE } }),
      this.prisma.user.count({ where: { role: Role.VENDOR, status: AccountStatus.PENDING } }),
      this.prisma.product.count({ where: { deletedAt: null } }),
      this.prisma.product.count({ where: { status: 'PENDING', deletedAt: null } }),
      this.prisma.category.count({ where: { deletedAt: null } }),
      this.prisma.brand.count({ where: { deletedAt: null } }),
    ]);

    return {
      totalCustomers,
      totalVendors,
      activeVendors,
      pendingVendorApprovals,
      totalProducts,
      totalCategories,
      pendingCategories: 0,
      totalBrands,
      pendingBrands: 0,
      pendingProducts,
      totalCompletedOrders: 0,
      totalCompletedOrdersRevenue: 0,
    };
  }
}
