import { Injectable } from '@nestjs/common';
import { IVendorDashboardRepository } from '../interfaces/vendor-dashboard-repository.interface';
import { PrismaService } from '../../../database/prisma.service';

@Injectable()
export class VendorDashboardRepository implements IVendorDashboardRepository {
  constructor(private readonly prisma: PrismaService) {}

  async getProductsCount(vendorId: string): Promise<{
    total: number;
    active: number;
    outOfStock: number;
    lowStock: number;
  }> {
    const [total, active, outOfStock, lowStock] = await Promise.all([
      this.prisma.product.count({ where: { vendorId, deletedAt: null } }),
      this.prisma.product.count({ where: { vendorId, status: 'ACTIVE', deletedAt: null } }),
      this.prisma.product.count({ where: { vendorId, stock: 0, deletedAt: null } }),
      this.prisma.product.count({ where: { vendorId, stock: { gt: 0, lte: 10 }, deletedAt: null } }),
    ]);

    return { total, active, outOfStock, lowStock };
  }

  async getOrdersCountAndRevenue(vendorId: string): Promise<{
    totalOrders: number;
    pendingOrders: number;
    ordersToDispatch: number;
    completedOrders: number;
    totalRevenue: number;
    currentMonthRevenue: number;
    todayRevenue: number;
    todayOrders: number;
  }> {
    const summary: any[] = await this.prisma.$queryRaw`
      SELECT 
        COUNT(DISTINCT o.id)::int as "totalOrders",
        COUNT(DISTINCT CASE WHEN o.status = 'PENDING' THEN o.id END)::int as "pendingOrders",
        COUNT(DISTINCT CASE WHEN o.status IN ('PENDING', 'CONFIRMED', 'PROCESSING') THEN o.id END)::int as "ordersToDispatch",
        COUNT(DISTINCT CASE WHEN o.status IN ('COMPLETED', 'DELIVERED') THEN o.id END)::int as "completedOrders",
        COALESCE(SUM(CASE WHEN o.status != 'CANCELLED' THEN oi.total_price END), 0)::float as "totalRevenue",
        COALESCE(SUM(CASE WHEN o.status != 'CANCELLED' AND o.created_at >= DATE_TRUNC('month', CURRENT_DATE) THEN oi.total_price END), 0)::float as "currentMonthRevenue",
        COALESCE(SUM(CASE WHEN o.status != 'CANCELLED' AND o.created_at >= DATE_TRUNC('day', CURRENT_DATE) THEN oi.total_price END), 0)::float as "todayRevenue",
        COUNT(DISTINCT CASE WHEN o.created_at >= DATE_TRUNC('day', CURRENT_DATE) THEN o.id END)::int as "todayOrders"
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      WHERE oi.vendor_id = ${vendorId}
    `;

    return summary[0] || {
      totalOrders: 0,
      pendingOrders: 0,
      ordersToDispatch: 0,
      completedOrders: 0,
      totalRevenue: 0,
      currentMonthRevenue: 0,
      todayRevenue: 0,
      todayOrders: 0,
    };
  }

  async getVendorKycStatus(vendorId: string): Promise<{
    kycStatus: string;
    hasProfile: boolean;
    storeName?: string;
  }> {
    const user = await this.prisma.user.findUnique({
      where: { id: vendorId },
      include: { vendorProfile: true },
    });
    return {
      kycStatus: user?.kycStatus || 'NOT_SUBMITTED',
      hasProfile: !!user?.vendorProfile,
      storeName: user?.vendorProfile?.storeName,
    };
  }

  async getSalesOverview(
    vendorId: string,
    startDate?: Date,
    endDate?: Date,
  ): Promise<{
    dailySales: Array<{ date: string; amount: number; count: number }>;
    weeklySales: Array<{ week: string; amount: number; count: number }>;
    monthlySales: Array<{ month: string; amount: number; count: number }>;
  }> {
    const [dailySales, weeklySales, monthlySales] = await Promise.all([
      this.prisma.$queryRaw<any[]>`
        SELECT 
          TO_CHAR(o.created_at, 'YYYY-MM-DD') as date,
          COALESCE(SUM(oi.total_price), 0)::float as amount,
          COUNT(DISTINCT o.id)::int as count
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        WHERE oi.vendor_id = ${vendorId}
          AND o.status != 'CANCELLED'
          AND (${startDate}::timestamp IS NULL OR o.created_at >= ${startDate})
          AND (${endDate}::timestamp IS NULL OR o.created_at <= ${endDate})
        GROUP BY TO_CHAR(o.created_at, 'YYYY-MM-DD')
        ORDER BY date ASC
      `,
      this.prisma.$queryRaw<any[]>`
        SELECT 
          TO_CHAR(DATE_TRUNC('week', o.created_at), 'YYYY-MM-DD') as week,
          COALESCE(SUM(oi.total_price), 0)::float as amount,
          COUNT(DISTINCT o.id)::int as count
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        WHERE oi.vendor_id = ${vendorId}
          AND o.status != 'CANCELLED'
          AND (${startDate}::timestamp IS NULL OR o.created_at >= ${startDate})
          AND (${endDate}::timestamp IS NULL OR o.created_at <= ${endDate})
        GROUP BY DATE_TRUNC('week', o.created_at)
        ORDER BY week ASC
      `,
      this.prisma.$queryRaw<any[]>`
        SELECT 
          TO_CHAR(DATE_TRUNC('month', o.created_at), 'YYYY-MM') as month,
          COALESCE(SUM(oi.total_price), 0)::float as amount,
          COUNT(DISTINCT o.id)::int as count
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        WHERE oi.vendor_id = ${vendorId}
          AND o.status != 'CANCELLED'
          AND (${startDate}::timestamp IS NULL OR o.created_at >= ${startDate})
          AND (${endDate}::timestamp IS NULL OR o.created_at <= ${endDate})
        GROUP BY DATE_TRUNC('month', o.created_at)
        ORDER BY month ASC
      `,
    ]);

    return {
      dailySales: dailySales || [],
      weeklySales: weeklySales || [],
      monthlySales: monthlySales || [],
    };
  }

  async getRecentOrders(
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
  > {
    const orders = await this.prisma.$queryRaw<any[]>`
      SELECT 
        o.order_number as "orderNumber",
        u.full_name as "customerName",
        o.status as "orderStatus",
        SUM(oi.total_price)::float as "amount",
        o.created_at as "createdAt"
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN users u ON o.customer_id = u.id
      WHERE oi.vendor_id = ${vendorId}
      GROUP BY o.id, o.order_number, u.full_name, o.status, o.created_at
      ORDER BY o.created_at DESC
      LIMIT ${limit} OFFSET ${offset}
    `;

    return orders || [];
  }

  async getLowStockProducts(
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
  > {
    const products = await this.prisma.product.findMany({
      where: {
        vendorId,
        stock: {
          lt: threshold,
        },
        deletedAt: null,
      },
      select: {
        id: true,
        name: true,
        sellingPrice: true,
        stock: true,
        status: true,
      },
      orderBy: {
        stock: 'asc',
      },
    });

    return products.map((p) => ({
      id: p.id,
      name: p.name,
      price: p.sellingPrice,
      stock: p.stock,
      isActive: p.status === 'ACTIVE',
    }));
  }
}
