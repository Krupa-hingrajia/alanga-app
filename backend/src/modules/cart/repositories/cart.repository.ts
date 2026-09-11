import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { ICartRepository } from '../interfaces/cart-repository.interface';

@Injectable()
export class CartRepository implements ICartRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCustomer(customerId: string): Promise<any[]> {
    return this.prisma.cartItem.findMany({
      where: { customerId },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] },
            shipping: true,
            brand: { select: { id: true, name: true, logo: true } },
            category: { select: { id: true, name: true } },
          },
        },
        productVariant: {
          include: {
            images: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findById(id: string): Promise<any | null> {
    return this.prisma.cartItem.findUnique({
      where: { id },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null } },
            shipping: true,
            brand: { select: { id: true, name: true, logo: true } },
            category: { select: { id: true, name: true } },
          },
        },
        productVariant: {
          include: {
            images: { where: { deletedAt: null } },
          },
        },
      },
    });
  }

  async findExistingItem(customerId: string, productId: string, productVariantId: string): Promise<any | null> {
    return this.prisma.cartItem.findUnique({
      where: {
        customerId_productId_productVariantId: {
          customerId,
          productId,
          productVariantId,
        },
      },
      include: {
        productVariant: true,
      },
    });
  }

  async create(data: { customerId: string; productId: string; productVariantId: string; quantity: number }): Promise<any> {
    return this.prisma.cartItem.create({
      data: {
        customerId: data.customerId,
        productId: data.productId,
        productVariantId: data.productVariantId,
        quantity: data.quantity,
      },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null } },
            shipping: true,
            brand: { select: { id: true, name: true, logo: true } },
            category: { select: { id: true, name: true } },
          },
        },
        productVariant: {
          include: {
            images: { where: { deletedAt: null } },
          },
        },
      },
    });
  }

  async updateQuantity(id: string, quantity: number): Promise<any> {
    return this.prisma.cartItem.update({
      where: { id },
      data: { quantity },
      include: {
        product: {
          include: {
            productImages: { where: { deletedAt: null } },
            shipping: true,
            brand: { select: { id: true, name: true, logo: true } },
            category: { select: { id: true, name: true } },
          },
        },
        productVariant: {
          include: {
            images: { where: { deletedAt: null } },
          },
        },
      },
    });
  }

  async delete(id: string): Promise<any> {
    return this.prisma.cartItem.delete({
      where: { id },
    });
  }

  async clearCustomerCart(customerId: string): Promise<any> {
    return this.prisma.cartItem.deleteMany({
      where: { customerId },
    });
  }
}
