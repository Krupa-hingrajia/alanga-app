import { Injectable, BadRequestException } from '@nestjs/common';
import { CartRepository } from '../../cart/repositories/cart.repository';
import { AddressRepository } from '../../addresses/repositories/address.repository';

@Injectable()
export class CheckoutService {
  constructor(
    private readonly cartRepository: CartRepository,
    private readonly addressRepository: AddressRepository,
  ) {}

  async getCheckoutSummary(customerId: string) {
    const rawCartItems = await this.cartRepository.findByCustomer(customerId);
    const defaultAddress = await this.addressRepository.findDefault(customerId);
    const allAddresses = await this.addressRepository.findByCustomer(customerId);

    if (rawCartItems.length === 0) {
      throw new BadRequestException('Shopping cart is empty. Add items to cart before proceeding to checkout.');
    }

    let subtotal = 0;
    let shippingCharge = 0;
    let minDeliveryDays = 3;
    let maxDeliveryDays = 7;

    const items = rawCartItems.map((cartItem) => {
      const product = cartItem.product || {};
      const variant = cartItem.productVariant || {};
      const shipping = product.shipping || {};

      const unitPrice = Number(variant.price ?? product.sellingPrice ?? 0);
      const itemSubtotal = unitPrice * cartItem.quantity;

      // Shipping calculation
      let itemShippingFee = 0;
      if (shipping.isFreeShipping) {
        itemShippingFee = 0;
      } else if (shipping.freeShippingAboveAmount && itemSubtotal >= shipping.freeShippingAboveAmount) {
        itemShippingFee = 0;
      } else {
        itemShippingFee = Number(shipping.shippingCharge ?? 0);
      }

      if (shipping.estimatedDeliveryMinDays && shipping.estimatedDeliveryMinDays > minDeliveryDays) {
        minDeliveryDays = shipping.estimatedDeliveryMinDays;
      }
      if (shipping.estimatedDeliveryMaxDays && shipping.estimatedDeliveryMaxDays > maxDeliveryDays) {
        maxDeliveryDays = shipping.estimatedDeliveryMaxDays;
      }

      subtotal += itemSubtotal;
      shippingCharge += itemShippingFee;

      // Determine product image
      let imageUrl = '';
      if (variant.images && variant.images.length > 0) {
        imageUrl = variant.images[0].imageUrl;
      } else if (product.productImages && product.productImages.length > 0) {
        imageUrl = product.productImages[0].imageUrl;
      } else {
        imageUrl = product.primaryImageUrl || product.image || '';
      }

      const availableStock = variant.stock ?? product.stock ?? 0;
      const isOutOfStock = availableStock <= 0 || cartItem.quantity > availableStock;

      return {
        cartItemId: cartItem.id,
        productId: product.id,
        variantId: variant.id,
        productName: product.name,
        variantName: variant.variantName || 'Default Variant',
        sku: variant.sku || product.sku || '',
        quantity: cartItem.quantity,
        unitPrice,
        itemSubtotal,
        itemShippingFee,
        totalItemCost: itemSubtotal + itemShippingFee,
        imageUrl,
        stock: availableStock,
        isOutOfStock,
        variantAttributes: variant.attributes || {},
      };
    });

    const grandTotal = subtotal + shippingCharge;

    const hasOutOfStockItems = items.some((item) => item.isOutOfStock);

    return {
      items,
      itemCount: items.length,
      subtotal,
      shippingCharge,
      grandTotal,
      hasOutOfStockItems,
      defaultAddress: defaultAddress || (allAddresses.length > 0 ? allAddresses[0] : null),
      savedAddressesCount: allAddresses.length,
      estimatedDelivery: {
        minDays: minDeliveryDays,
        maxDays: maxDeliveryDays,
        displayRange: `${minDeliveryDays} - ${maxDeliveryDays} Business Days`,
      },
    };
  }
}
