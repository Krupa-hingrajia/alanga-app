import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { IOrderRepository } from '../interfaces/order-repository.interface';
import { AdminOrderQueryDto } from '../dto/admin-order-query.dto';

@Injectable()
export class OrderRepository implements IOrderRepository {
  constructor(private readonly prisma: PrismaService) {}

  private get client() {
    return this.prisma;
  }

  async createOrder(data: any, tx?: any): Promise<any> {
    const prismaClient = tx || this.prisma;
    return prismaClient.order.create({
      data: {
        orderNumber: data.orderNumber,
        customerId: data.customerId,
        addressId: data.addressId,
        shippingAddressSnapshot: data.shippingAddressSnapshot,
        subtotal: data.subtotal,
        shippingCharge: data.shippingCharge,
        totalAmount: data.totalAmount,
        paymentMethod: data.paymentMethod || 'COD',
        paymentStatus: data.paymentStatus || 'PENDING',
        status: data.status || 'PENDING',
        notes: data.notes,
        orderItems: {
          create: data.orderItems,
        },
      },
      include: {
        orderItems: true,
        address: true,
      },
    });
  }

  async findById(id: string): Promise<any | null> {
    return this.prisma.order.findFirst({
      where: { id, deletedAt: null },
      include: {
        address: true,
        customer: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phoneNumber: true,
          },
        },
        orderItems: {
          include: {
            product: {
              include: {
                vendor: {
                  select: {
                    id: true,
                    fullName: true,
                    email: true,
                    phoneNumber: true,
                  },
                },
                productImages: { where: { deletedAt: null } },
              },
            },
            productVariant: {
              include: {
                images: { where: { deletedAt: null } },
              },
            },
          },
        },
      },
    });
  }

  async findByOrderNumber(orderNumber: string): Promise<any | null> {
    return this.prisma.order.findFirst({
      where: { orderNumber, deletedAt: null },
      include: {
        address: true,
        orderItems: true,
      },
    });
  }

  async findByCustomer(customerId: string): Promise<any[]> {
    return this.prisma.order.findMany({
      where: { customerId, deletedAt: null },
      include: {
        address: true,
        orderItems: {
          include: {
            product: {
              select: {
                id: true,
                name: true,
                vendorId: true,
                image: true,
                productImages: { where: { deletedAt: null } },
              },
            },
            productVariant: {
              include: {
                images: { where: { deletedAt: null } },
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findByVendor(vendorId: string): Promise<any[]> {
    return this.prisma.order.findMany({
      where: {
        deletedAt: null,
        orderItems: {
          some: {
            OR: [
              { vendorId },
              { product: { vendorId } },
            ],
          },
        },
      },
      include: {
        address: true,
        customer: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phoneNumber: true,
          },
        },
        orderItems: {
          where: {
            OR: [
              { vendorId },
              { product: { vendorId } },
            ],
          },
          include: {
            product: {
              include: {
                vendor: {
                  select: {
                    id: true,
                    fullName: true,
                    email: true,
                    phoneNumber: true,
                  },
                },
                productImages: { where: { deletedAt: null } },
              },
            },
            productVariant: {
              include: {
                images: { where: { deletedAt: null } },
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findVendorOrderById(vendorId: string, orderId: string): Promise<any | null> {
    return this.prisma.order.findFirst({
      where: {
        id: orderId,
        deletedAt: null,
        orderItems: {
          some: {
            OR: [
              { vendorId },
              { product: { vendorId } },
            ],
          },
        },
      },
      include: {
        address: true,
        customer: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phoneNumber: true,
          },
        },
        orderItems: {
          where: {
            OR: [
              { vendorId },
              { product: { vendorId } },
            ],
          },
          include: {
            product: {
              include: {
                vendor: {
                  select: {
                    id: true,
                    fullName: true,
                    email: true,
                    phoneNumber: true,
                  },
                },
                productImages: { where: { deletedAt: null } },
              },
            },
            productVariant: {
              include: {
                images: { where: { deletedAt: null } },
              },
            },
          },
        },
      },
    });
  }

  async findAll(query: AdminOrderQueryDto): Promise<{ items: any[]; total: number; page: number; limit: number }> {
    const { vendorId, customerId, status, startDate, endDate, page = 1, limit = 10 } = query;
    const skip = (page - 1) * limit;

    const where: any = { deletedAt: null };

    if (customerId) where.customerId = customerId;
    if (status) where.status = status;
    if (vendorId) {
      where.orderItems = {
        some: {
          OR: [
            { vendorId },
            { product: { vendorId } },
          ],
        },
      };
    }
    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) where.createdAt.gte = new Date(startDate);
      if (endDate) where.createdAt.lte = new Date(endDate);
    }

    const [items, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        skip,
        take: limit,
        include: {
          address: true,
          customer: {
            select: {
              id: true,
              fullName: true,
              email: true,
              phoneNumber: true,
            },
          },
          orderItems: {
            include: {
              product: {
                include: {
                  vendor: {
                    select: {
                      id: true,
                      fullName: true,
                      email: true,
                      phoneNumber: true,
                    },
                  },
                  productImages: { where: { deletedAt: null } },
                },
              },
              productVariant: {
                include: {
                  images: { where: { deletedAt: null } },
                },
              },
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.order.count({ where }),
    ]);

    return { items, total, page, limit };
  }

  async updateStatus(orderId: string, status: string, tx?: any): Promise<any> {
    const prismaClient = tx || this.prisma;
    return prismaClient.order.update({
      where: { id: orderId },
      data: { status },
    });
  }

  async updateOrderItemStatus(orderItemId: string, status: string, tx?: any): Promise<any> {
    const prismaClient = tx || this.prisma;
    return prismaClient.orderItem.update({
      where: { id: orderItemId },
      data: { status },
    });
  }

  async countTodayOrders(): Promise<number> {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    return this.prisma.order.count({
      where: {
        createdAt: {
          gte: startOfDay,
          lte: endOfDay,
        },
      },
    });
  }
}
