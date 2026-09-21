import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { OrderRepository } from '../repositories/order.repository';
import { AddressRepository } from '../../addresses/repositories/address.repository';
import { CartRepository } from '../../cart/repositories/cart.repository';
import { PlaceOrderDto } from '../dto/place-order.dto';
import { UpdateOrderStatusDto, OrderStatus } from '../dto/update-order-status.dto';
import { AdminOrderQueryDto } from '../dto/admin-order-query.dto';
import { calculateItemShippingFee } from '../utils/shipping-calculator.util';

@Injectable()
export class OrderService {
  private readonly logger = new Logger(OrderService.name);

  private readonly validVendorTransitions: Record<string, string[]> = {
    PENDING: ['CONFIRMED', 'CANCELLED'],
    CONFIRMED: ['PROCESSING', 'CANCELLED'],
    PROCESSING: ['PACKED', 'CANCELLED'],
    PACKED: ['SHIPPED', 'CANCELLED'],
    SHIPPED: ['OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED'],
    OUT_FOR_DELIVERY: ['DELIVERED', 'CANCELLED'],
    DELIVERED: [],
    PARTIALLY_DELIVERED: ['DELIVERED'],
    CANCELLED: [],
  };

  constructor(
    private readonly prisma: PrismaService,
    private readonly orderRepository: OrderRepository,
    private readonly addressRepository: AddressRepository,
    private readonly cartRepository: CartRepository,
  ) {}

  private generateOrderNumber(): string {
    const year = new Date().getFullYear();
    const timestamp = Date.now().toString(36).toUpperCase();
    const randomSuffix = Math.random().toString(36).substring(2, 6).toUpperCase();
    return `ALG-${year}-${timestamp}-${randomSuffix}`;
  }

  async placeOrder(customerId: string, dto: PlaceOrderDto) {
    // 1. Fetch Cart Items
    const rawCartItems = await this.cartRepository.findByCustomer(customerId);
    if (rawCartItems.length === 0) {
      throw new BadRequestException('Your shopping cart is empty. Cannot place an order.');
    }

    // 2. Fetch & Validate Address
    const address = await this.addressRepository.findById(dto.addressId);
    if (!address || address.customerId !== customerId) {
      throw new NotFoundException(`Shipping address with ID "${dto.addressId}" not found.`);
    }

    // 3. Prepare Address Snapshot
    const shippingAddressSnapshot = {
      fullName: address.fullName,
      mobileNumber: address.mobileNumber,
      alternateMobile: address.alternateMobile || null,
      addressLine1: address.addressLine1,
      addressLine2: address.addressLine2 || null,
      landmark: address.landmark || null,
      city: address.city,
      state: address.state,
      country: address.country || 'India',
      postalCode: address.postalCode,
      addressType: address.addressType,
    };

    // 4. Pre-validate Product & Variant active statuses
    for (const item of rawCartItems) {
      const product = item.product;
      const variant = item.productVariant;

      if (!product || product.deletedAt !== null) {
        throw new BadRequestException(`Product in cart is no longer available.`);
      }
      if (product.status !== 'ACTIVE') {
        throw new BadRequestException(`Product "${product.name}" is no longer active.`);
      }
      if (!variant || variant.deletedAt !== null) {
        throw new BadRequestException(`Product variant in cart is no longer available.`);
      }
      if (variant.status !== 'ACTIVE') {
        throw new BadRequestException(`Variant "${variant.variantName}" for "${product.name}" is not active.`);
      }
    }

    // 5. Generate Collision-Resistant Order Number
    const orderNumber = this.generateOrderNumber();

    // 6. Execute Order Creation & Stock Deduction atomically inside Prisma Transaction
    const result = await this.prisma.$transaction(async (tx) => {
      let subtotal = 0;
      let totalShippingCharge = 0;
      const orderItemsData = [];

      for (const item of rawCartItems) {
        const product = item.product;
        const variant = item.productVariant;

        // Atomic conditional decrement: Only decrement if stock >= requested quantity
        const updateResult = await tx.productVariant.updateMany({
          where: {
            id: variant.id,
            stock: { gte: item.quantity },
            status: 'ACTIVE',
            deletedAt: null,
          },
          data: {
            stock: { decrement: item.quantity },
          },
        });

        if (updateResult.count === 0) {
          throw new BadRequestException(
            `Insufficient stock for "${product.name} - ${variant.variantName}". Requested: ${item.quantity}. Order could not be placed.`,
          );
        }

        // Also update Inventory table if record exists
        await tx.inventory.updateMany({
          where: { productVariantId: variant.id },
          data: {
            stockQuantity: { decrement: item.quantity },
            availableStock: { decrement: item.quantity },
          },
        });

        const unitPrice = Number(variant.price ?? product.sellingPrice ?? 0);
        const itemSubtotal = unitPrice * item.quantity;
        const itemShippingFee = calculateItemShippingFee(product.shipping, itemSubtotal);
        const itemTotal = itemSubtotal + itemShippingFee;

        subtotal += itemSubtotal;
        totalShippingCharge += itemShippingFee;

        orderItemsData.push({
          vendorId: product.vendorId,
          productId: product.id,
          productVariantId: variant.id,
          productNameSnapshot: product.name,
          variantNameSnapshot: variant.variantName || 'Default Variant',
          variantAttributesSnapshot: variant.attributes || {},
          sku: variant.sku || product.sku || '',
          quantity: item.quantity,
          unitPrice,
          shippingCharge: itemShippingFee,
          totalPrice: itemTotal,
          status: 'PENDING',
        });
      }

      const grandTotal = subtotal + totalShippingCharge;

      // Create Order
      const newOrder = await tx.order.create({
        data: {
          orderNumber,
          customerId,
          addressId: address.id,
          shippingAddressSnapshot,
          subtotal,
          shippingCharge: totalShippingCharge,
          totalAmount: grandTotal,
          paymentMethod: dto.paymentMethod || 'COD',
          paymentStatus: dto.paymentMethod === 'COD' ? 'PENDING' : 'PENDING',
          status: 'PENDING',
          notes: dto.notes || null,
          orderItems: {
            create: orderItemsData,
          },
        },
        include: {
          orderItems: true,
          address: true,
        },
      });

      // Clear Customer Cart
      await tx.cartItem.deleteMany({
        where: { customerId },
      });

      return newOrder;
    });

    return result;
  }

  async getCustomerOrders(customerId: string) {
    return this.orderRepository.findByCustomer(customerId);
  }

  async getCustomerOrderById(customerId: string, orderId: string) {
    const order = await this.orderRepository.findById(orderId);
    if (!order || order.customerId !== customerId) {
      throw new NotFoundException(`Order with ID "${orderId}" not found.`);
    }
    return order;
  }

  async getVendorOrders(vendorId: string) {
    this.logger.log(`[getVendorOrders] Fetching orders for logged-in Vendor ID: ${vendorId}`);
    const orders = await this.orderRepository.findByVendor(vendorId);
    this.logger.log(`[getVendorOrders] Retrieved ${orders.length} order(s) for Vendor ID: ${vendorId}`);

    for (const order of orders) {
      // If all items for this vendor in this order share the same status, reflect that status on the vendor's view
      if (order.orderItems && order.orderItems.length > 0) {
        const itemStatuses = new Set(order.orderItems.map((i: any) => i.status));
        if (itemStatuses.size === 1) {
          order.status = order.orderItems[0].status;
        }
      }
      for (const item of order.orderItems || []) {
        const itemVendorId = item.vendorId || item.product?.vendorId;
        this.logger.log(
          `[Vendor Order Item Flow] Logged-in Vendor ID: ${vendorId} | Product Vendor ID: ${itemVendorId} | Order ID: ${order.id} (${order.orderNumber}) | OrderItem ID: ${item.id}`,
        );
      }
    }

    return orders;
  }

  async updateVendorOrderStatus(vendorId: string, orderId: string, dto: UpdateOrderStatusDto) {
    this.logger.log(
      `[updateVendorOrderStatus] Logged-in Vendor ID: ${vendorId} | Order ID: ${orderId} | Target Status: ${dto.status}`,
    );
    const order = await this.orderRepository.findById(orderId);
    if (!order) {
      throw new NotFoundException(`Order with ID "${orderId}" not found.`);
    }

    const vendorItems = order.orderItems.filter(
      (item: any) => item.vendorId === vendorId || item.product?.vendorId === vendorId,
    );
    if (vendorItems.length === 0) {
      this.logger.warn(
        `[updateVendorOrderStatus] Forbidden: Logged-in Vendor ID: ${vendorId} does not own any items in Order ID: ${orderId}`,
      );
      throw new ForbiddenException(`You do not have permission to modify this order.`);
    }

    // Validate status transitions for vendor items to prevent invalid status jumps
    for (const item of vendorItems) {
      const allowed = this.validVendorTransitions[item.status] || [];
      if (item.status !== dto.status && !allowed.includes(dto.status)) {
        throw new BadRequestException(
          `Cannot transition item "${item.productNameSnapshot}" from ${item.status} to ${dto.status}.`,
        );
      }
    }

    // Update Vendor items status & restore stock on cancellation atomically
    await this.prisma.$transaction(async (tx) => {
      for (const item of vendorItems) {
        if (item.status !== 'CANCELLED' && dto.status === 'CANCELLED') {
          // Restore Variant Stock and Inventory
          if (item.productVariantId) {
            await tx.productVariant.update({
              where: { id: item.productVariantId },
              data: { stock: { increment: item.quantity } },
            });
            await tx.inventory.updateMany({
              where: { productVariantId: item.productVariantId },
              data: {
                stockQuantity: { increment: item.quantity },
                availableStock: { increment: item.quantity },
              },
            });
          }
        }

        await tx.orderItem.update({
          where: { id: item.id },
          data: { status: dto.status },
        });
      }

      // Roll up order status progressively based on all non-cancelled items
      const updatedOrder = await tx.order.findUnique({
        where: { id: orderId },
        include: { orderItems: true },
      });

      if (updatedOrder && updatedOrder.orderItems) {
        const nonCancelled = updatedOrder.orderItems.filter((i: any) => i.status !== 'CANCELLED');
        const isAllDelivered = nonCancelled.length > 0 && nonCancelled.every((i: any) => i.status === 'DELIVERED');
        const hasDelivered = nonCancelled.some((i: any) => i.status === 'DELIVERED');
        const isAllShipped = nonCancelled.length > 0 && nonCancelled.every((i: any) => ['SHIPPED', 'OUT_FOR_DELIVERY', 'DELIVERED'].includes(i.status));
        const isAllPacked = nonCancelled.length > 0 && nonCancelled.every((i: any) => ['PACKED', 'SHIPPED', 'OUT_FOR_DELIVERY', 'DELIVERED'].includes(i.status));
        const isAllProcessing = nonCancelled.length > 0 && nonCancelled.every((i: any) => ['PROCESSING', 'PACKED', 'SHIPPED', 'OUT_FOR_DELIVERY', 'DELIVERED'].includes(i.status));
        const isAllConfirmed = nonCancelled.length > 0 && nonCancelled.every((i: any) => ['CONFIRMED', 'PROCESSING', 'PACKED', 'SHIPPED', 'OUT_FOR_DELIVERY', 'DELIVERED'].includes(i.status));

        let newOrderStatus = updatedOrder.status;
        if (nonCancelled.length === 0) {
          newOrderStatus = 'CANCELLED';
        } else if (isAllDelivered) {
          newOrderStatus = 'DELIVERED';
        } else if (hasDelivered) {
          newOrderStatus = 'PARTIALLY_DELIVERED';
        } else if (isAllShipped) {
          newOrderStatus = 'SHIPPED';
        } else if (isAllPacked) {
          newOrderStatus = 'PACKED';
        } else if (isAllProcessing) {
          newOrderStatus = 'PROCESSING';
        } else if (isAllConfirmed) {
          newOrderStatus = 'CONFIRMED';
        }

        if (newOrderStatus !== updatedOrder.status) {
          await tx.order.update({
            where: { id: orderId },
            data: { status: newOrderStatus },
          });
        }
      }
    });

    const result = await this.orderRepository.findVendorOrderById(vendorId, orderId);
    if (result && result.orderItems && result.orderItems.length > 0) {
      const itemStatuses = new Set(result.orderItems.map((i: any) => i.status));
      if (itemStatuses.size === 1) {
        result.status = result.orderItems[0].status;
      }
    }
    return result || this.orderRepository.findById(orderId);
  }

  async getAdminOrders(query: AdminOrderQueryDto) {
    const result = await this.orderRepository.findAll(query);
    if (query.vendorId && result.items) {
      for (const order of result.items) {
        const vendorItems = order.orderItems?.filter(
          (i: any) => i.vendorId === query.vendorId || i.product?.vendorId === query.vendorId,
        );
        if (vendorItems && vendorItems.length > 0) {
          const itemStatuses = new Set(vendorItems.map((i: any) => i.status));
          if (itemStatuses.size === 1) {
            order.status = vendorItems[0].status;
          }
        }
      }
    }
    return result;
  }

  async getAdminOrderById(orderId: string) {
    const order = await this.orderRepository.findById(orderId);
    if (!order) {
      throw new NotFoundException(`Order with ID "${orderId}" not found.`);
    }
    return order;
  }

  async updateAdminOrderStatus(orderId: string, dto: UpdateOrderStatusDto) {
    const order = await this.orderRepository.findById(orderId);
    if (!order) {
      throw new NotFoundException(`Order with ID "${orderId}" not found.`);
    }

    await this.prisma.$transaction(async (tx) => {
      // If transitioning to CANCELLED, restore variant stock and inventory for active items
      if (order.status !== 'CANCELLED' && dto.status === 'CANCELLED') {
        for (const item of order.orderItems || []) {
          if (item.status !== 'CANCELLED' && item.productVariantId) {
            await tx.productVariant.update({
              where: { id: item.productVariantId },
              data: { stock: { increment: item.quantity } },
            });
            await tx.inventory.updateMany({
              where: { productVariantId: item.productVariantId },
              data: {
                stockQuantity: { increment: item.quantity },
                availableStock: { increment: item.quantity },
              },
            });
          }
        }
      }

      await tx.order.update({
        where: { id: orderId },
        data: { status: dto.status },
      });
      await tx.orderItem.updateMany({
        where: { orderId },
        data: { status: dto.status },
      });
    });

    return this.orderRepository.findById(orderId);
  }
}
