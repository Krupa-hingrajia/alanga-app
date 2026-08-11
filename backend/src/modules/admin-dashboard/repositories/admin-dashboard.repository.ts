import { Injectable } from '@nestjs/common';
import { IAdminDashboardRepository } from '../interfaces/admin-dashboard-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { Role, UserStatus } from '@prisma/client';

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
    totalOrders: number;
    totalRevenue: number;
  }> {
    const [
      totalCustomers,
      totalVendors,
      activeVendors,
      pendingVendorApprovals,
      totalProducts,
      totalCategories,
      totalOrders,
      revenueAggregate,
    ] = await Promise.all([
      this.prisma.user.count({ where: { role: Role.CUSTOMER } }),
      this.prisma.user.count({ where: { role: Role.VENDOR } }),
      this.prisma.user.count({ where: { role: Role.VENDOR, status: UserStatus.ACTIVE } }),
      this.prisma.user.count({ where: { role: Role.VENDOR, status: UserStatus.PENDING } }),
      this.prisma.product.count({ where: {} }),
      this.prisma.category.count({ where: { deletedAt: null } }),
      this.prisma.order.count({ where: {} }),
      this.prisma.order.aggregate({
        where: { status: 'COMPLETED' },
        _sum: {
          totalAmount: true,
        },
      }),
    ]);

    return {
      totalCustomers,
      totalVendors,
      activeVendors,
      pendingVendorApprovals,
      totalProducts,
      totalCategories,
      totalOrders,
      totalRevenue: revenueAggregate._sum.totalAmount || 0,
    };
  }
}
