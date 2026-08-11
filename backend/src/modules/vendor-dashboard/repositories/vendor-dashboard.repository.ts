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
  }> {
    const [total, active, outOfStock] = await Promise.all([
      this.prisma.product.count({ where: { vendorId, deletedAt: null } }),
      this.prisma.product.count({ where: { vendorId, status: 'ACTIVE', deletedAt: null } }),
      this.prisma.product.count({ where: { vendorId, stock: 0, deletedAt: null } }),
    ]);

    return { total, active, outOfStock };
  }

  async getOrdersCountAndRevenue(vendorId: string): Promise<{
    totalOrders: number;
    pendingOrders: number;
    completedOrders: number;
    totalRevenue: number;
    currentMonthRevenue: number;
  }> {
    const summary: any[] = await this.prisma.$queryRaw`
      SELECT 
        COUNT(DISTINCT o.id)::int as "totalOrders",
        COUNT(DISTINCT CASE WHEN o.status = 'PENDING' THEN o.id END)::int as "pendingOrders",
        COUNT(DISTINCT CASE WHEN o.status = 'COMPLETED' THEN o.id END)::int as "completedOrders",
        COALESCE(SUM(CASE WHEN o.status = 'COMPLETED' THEN oi.quantity * oi.price END), 0)::float as "totalRevenue",
        COALESCE(SUM(CASE WHEN o.status = 'COMPLETED' AND o.created_at >= DATE_TRUNC('month', CURRENT_DATE) THEN oi.quantity * oi.price END), 0)::float as "currentMonthRevenue"
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE p.vendor_id = ${vendorId}
    `;

    return summary[0] || {
      totalOrders: 0,
      pendingOrders: 0,
      completedOrders: 0,
      totalRevenue: 0,
      currentMonthRevenue: 0,
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
          COALESCE(SUM(oi.quantity * oi.price), 0)::float as amount,
          COUNT(DISTINCT o.id)::int as count
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        JOIN products p ON oi.product_id = p.id
        WHERE p.vendor_id = ${vendorId}
          AND o.status = 'COMPLETED'
          AND (${startDate}::timestamp IS NULL OR o.created_at >= ${startDate})
          AND (${endDate}::timestamp IS NULL OR o.created_at <= ${endDate})
        GROUP BY TO_CHAR(o.created_at, 'YYYY-MM-DD')
        ORDER BY date ASC
      `,
      this.prisma.$queryRaw<any[]>`
        SELECT 
          TO_CHAR(DATE_TRUNC('week', o.created_at), 'YYYY-MM-DD') as week,
          COALESCE(SUM(oi.quantity * oi.price), 0)::float as amount,
          COUNT(DISTINCT o.id)::int as count
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        JOIN products p ON oi.product_id = p.id
        WHERE p.vendor_id = ${vendorId}
          AND o.status = 'COMPLETED'
          AND (${startDate}::timestamp IS NULL OR o.created_at >= ${startDate})
          AND (${endDate}::timestamp IS NULL OR o.created_at <= ${endDate})
        GROUP BY DATE_TRUNC('week', o.created_at)
        ORDER BY week ASC
      `,
      this.prisma.$queryRaw<any[]>`
        SELECT 
          TO_CHAR(DATE_TRUNC('month', o.created_at), 'YYYY-MM') as month,
          COALESCE(SUM(oi.quantity * oi.price), 0)::float as amount,
          COUNT(DISTINCT o.id)::int as count
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        JOIN products p ON oi.product_id = p.id
        WHERE p.vendor_id = ${vendorId}
          AND o.status = 'COMPLETED'
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
        SUM(oi.quantity * oi.price)::float as "amount",
        o.created_at as "createdAt"
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      JOIN users u ON o.customer_id = u.id
      WHERE p.vendor_id = ${vendorId}
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
