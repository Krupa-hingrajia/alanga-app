import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { OrderRepository } from '../repositories/order.repository';
import { AddressRepository } from '../../addresses/repositories/address.repository';
import { CartRepository } from '../../cart/repositories/cart.repository';
import { PlaceOrderDto } from '../dto/place-order.dto';
import { UpdateOrderStatusDto, OrderStatus } from '../dto/update-order-status.dto';
import { AdminOrderQueryDto } from '../dto/admin-order-query.dto';

@Injectable()
export class OrderService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly orderRepository: OrderRepository,
    private readonly addressRepository: AddressRepository,
    private readonly cartRepository: CartRepository,
  ) {}

  private async generateOrderNumber(): Promise<string> {
    const year = new Date().getFullYear();
    const countToday = await this.orderRepository.countTodayOrders();
    const totalCount = (await this.prisma.order.count()) + 1;
    const sequence = totalCount.toString().padStart(6, '0');
    return `ALG-${year}-${sequence}`;
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

    // 4. Validate All Products & Variants Stock
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

      const availableStock = variant.stock ?? 0;
      if (availableStock < item.quantity) {
        throw new BadRequestException(
          `Insufficient stock for "${product.name} - ${variant.variantName}". Requested: ${item.quantity}, Available: ${availableStock}.`,
        );
      }
    }

    // 5. Generate Order Number
    const orderNumber = await this.generateOrderNumber();

    // 6. Execute Order Creation & Stock Deduction in Prisma Transaction
    const result = await this.prisma.$transaction(async (tx) => {
      let subtotal = 0;
      let totalShippingCharge = 0;
      const orderItemsData = [];

      for (const item of rawCartItems) {
        const product = item.product;
        const variant = item.productVariant;
        const shipping = product.shipping || {};

        const unitPrice = Number(variant.price ?? product.sellingPrice ?? 0);
        const itemSubtotal = unitPrice * item.quantity;

        let itemShippingFee = 0;
        if (!shipping.isFreeShipping && (!shipping.freeShippingAboveAmount || itemSubtotal < shipping.freeShippingAboveAmount)) {
          itemShippingFee = Number(shipping.shippingCharge ?? 0);
        }

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

        // Atomic Stock Deduction
        await tx.productVariant.update({
          where: { id: variant.id },
          data: {
            stock: {
              decrement: item.quantity,
            },
          },
        });

        // Also update Inventory table if record exists
        await tx.inventory.updateMany({
          where: { productVariantId: variant.id },
          data: {
            stockQuantity: { decrement: item.quantity },
            availableStock: { decrement: item.quantity },
          },
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
    return this.orderRepository.findByVendor(vendorId);
  }

  async updateVendorOrderStatus(vendorId: string, orderId: string, dto: UpdateOrderStatusDto) {
    const order = await this.orderRepository.findById(orderId);
    if (!order) {
      throw new NotFoundException(`Order with ID "${orderId}" not found.`);
    }

    const vendorItems = order.orderItems.filter((item: any) => item.vendorId === vendorId);
    if (vendorItems.length === 0) {
      throw new ForbiddenException(`You do not have permission to modify this order.`);
    }

    // Update Vendor items status
    await this.prisma.$transaction(async (tx) => {
      for (const item of vendorItems) {
        await tx.orderItem.update({
          where: { id: item.id },
          data: { status: dto.status },
        });
      }

      // Check if all order items match or advance order status
      const updatedOrder = await tx.order.findUnique({
        where: { id: orderId },
        include: { orderItems: true },
      });

      if (updatedOrder && updatedOrder.orderItems) {
        const allStatuses = updatedOrder.orderItems.map((item: any) => item.status);
        const isAllSame = allStatuses.every((s: string) => s === dto.status);

        if (isAllSame) {
          await tx.order.update({
            where: { id: orderId },
            data: { status: dto.status },
          });
        }
      }
    });

    return this.orderRepository.findById(orderId);
  }

  async getAdminOrders(query: AdminOrderQueryDto) {
    return this.orderRepository.findAll(query);
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
