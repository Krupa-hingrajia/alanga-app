import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { ICartRepository } from '../interfaces/cart-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { AddToCartDto } from '../dto/add-to-cart.dto';
import { UpdateCartItemDto, CartUpdateAction } from '../dto/update-cart-item.dto';

@Injectable()
export class CartService {
  constructor(
    private readonly cartRepository: ICartRepository,
    private readonly prisma: PrismaService,
  ) {}

  private mapToCartItemDto(item: any) {
    const product = item.product || {};
    const variant = item.productVariant || null;

    // Image Rule: If Variant Images exist, return Variant Primary Image. Else return Product Primary Image.
    const getSelectedImageUrl = (prod: any, vr: any) => {
      if (vr && vr.images && vr.images.length > 0) {
        const primary = vr.images.find((img: any) => img.isPrimary) || vr.images[0];
        if (primary && primary.imageUrl) return primary.imageUrl;
      }
      const matchingImg = (prod.productImages || []).find((img: any) => img.productVariantId === vr?.id);
      if (matchingImg && matchingImg.imageUrl) return matchingImg.imageUrl;

      const commonImgs = (prod.productImages || []).filter((img: any) => !img.productVariantId);
      if (commonImgs.length > 0) {
        const primary = commonImgs.find((img: any) => img.isPrimary) || commonImgs[0];
        if (primary && primary.imageUrl) return primary.imageUrl;
      }
      if (prod.productImages && prod.productImages.length > 0) {
        return prod.productImages[0].imageUrl;
      }
      return prod.image || '';
    };

    const selectedImageUrl = getSelectedImageUrl(product, variant);
    const unitPrice = variant ? variant.price : (product.sellingPrice ?? 0);
    const itemTotal = unitPrice * item.quantity;
    const stock = variant ? (variant.stock ?? 0) : (product.stock ?? 0);

    const isOutOfStock = stock <= 0 || item.quantity > stock;
    let stockStatus = 'IN_STOCK';
    if (stock <= 0) {
      stockStatus = 'OUT_OF_STOCK';
    } else if (item.quantity > stock) {
      stockStatus = 'INSUFFICIENT_STOCK';
    } else if (stock <= 5) {
      stockStatus = 'LOW_STOCK';
    }

    return {
      id: item.id,
      productId: item.productId,
      productVariantId: item.productVariantId,
      quantity: item.quantity,
      unitPrice,
      itemTotal,
      selectedImageUrl,
      isOutOfStock,
      stock,
      stockStatus,
      product: {
        id: product.id,
        name: product.name,
        sku: product.sku,
        status: product.status,
        brand: product.brand,
        category: product.category,
      },
      variant: variant
        ? {
            id: variant.id,
            sku: variant.sku,
            variantName: variant.variantName,
            color: variant.color,
            size: variant.size,
            storage: variant.storage,
            attributes: variant.attributes,
            price: variant.price,
            stock: variant.stock ?? 0,
            status: variant.status,
          }
        : null,
      shipping: product.shipping || null,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    };
  }

  private calculateCartSummary(mappedItems: any[], rawItems: any[]) {
    let subtotal = 0;
    let totalItems = 0;

    for (const item of mappedItems) {
      totalItems += item.quantity;
      if (!item.isOutOfStock) {
        subtotal += item.itemTotal;
      }
    }

    // Compute shipping per product
    let shippingCharge = 0;
    const processedProductIds = new Set<string>();

    for (const raw of rawItems) {
      const product = raw.product;
      if (!product || processedProductIds.has(product.id)) continue;
      processedProductIds.add(product.id);

      const shipping = product.shipping;
      if (shipping) {
        if (shipping.isFreeShipping) {
          if (shipping.freeShippingAboveAmount && shipping.freeShippingAboveAmount > 0) {
            const productSubtotal = rawItems
              .filter((i) => i.productId === product.id)
              .reduce((acc, i) => acc + (i.productVariant?.price ?? 0) * i.quantity, 0);

            if (productSubtotal < shipping.freeShippingAboveAmount) {
              shippingCharge += shipping.shippingCharge ?? 0;
            }
          }
        } else {
          shippingCharge += shipping.shippingCharge ?? 0;
        }
      }
    }

    const estimatedTotal = subtotal + shippingCharge;
    const hasOutOfStockItems = mappedItems.some((i) => i.isOutOfStock);

    return {
      subtotal,
      shippingCharge,
      estimatedTotal,
      totalItems,
      itemCount: mappedItems.length,
      hasOutOfStockItems,
    };
  }

  async getCart(customerId: string) {
    const rawItems = await this.cartRepository.findByCustomer(customerId);
    const mappedItems = rawItems.map((item) => this.mapToCartItemDto(item));
    const summary = this.calculateCartSummary(mappedItems, rawItems);

    return {
      items: mappedItems,
      summary,
    };
  }

  async addToCart(customerId: string, dto: AddToCartDto) {
    const targetVariantId = dto.productVariantId || dto.variantId;

    // 1. Validate Product
    const product = await this.prisma.product.findFirst({
      where: { id: dto.productId, deletedAt: null },
    });
    if (!product) {
      throw new NotFoundException(`Product with ID "${dto.productId}" not found.`);
    }
    if (product.status !== 'ACTIVE') {
      throw new BadRequestException('Product is not active and cannot be added to cart.');
    }

    // 2. Resolve & Validate Variant
    let variantId = targetVariantId;
    if (!variantId) {
      let defaultVariant =
        (await this.prisma.productVariant.findFirst({
          where: { productId: dto.productId, deletedAt: null, isDefault: true },
        })) ||
        (await this.prisma.productVariant.findFirst({
          where: { productId: dto.productId, deletedAt: null, status: 'ACTIVE' },
        })) ||
        (await this.prisma.productVariant.findFirst({
          where: { productId: dto.productId, deletedAt: null },
        }));

      if (!defaultVariant) {
        defaultVariant = await this.prisma.productVariant.create({
          data: {
            productId: product.id,
            sku: `${product.sku}-DEF`,
            variantName: 'Default Variant',
            price: product.sellingPrice,
            mrp: product.mrp,
            stock: (product.stock && product.stock > 0) ? product.stock : 10,
            status: 'ACTIVE',
            isDefault: true,
            attributes: {},
          },
        });
      }
      variantId = defaultVariant.id;
    }

    const variant = await this.prisma.productVariant.findFirst({
      where: { id: variantId, deletedAt: null },
    });
    if (!variant) {
      throw new NotFoundException(`Product variant with ID "${variantId}" not found.`);
    }
    if (variant.productId !== product.id) {
      throw new BadRequestException('Selected variant does not belong to the specified product.');
    }
    if (variant.status !== 'ACTIVE') {
      throw new BadRequestException('Selected variant is not active.');
    }

    const availableStock = variant.stock ?? 0;
    if (availableStock <= 0) {
      throw new BadRequestException('Selected variant is out of stock.');
    }

    const requestedQuantity = dto.quantity || 1;
    if (requestedQuantity > availableStock) {
      throw new BadRequestException(`Requested quantity (${requestedQuantity}) exceeds available stock (${availableStock}).`);
    }

    // 3. Duplicate Rule: Check if same Product + Variant exists in Cart
    const existingItem = await this.cartRepository.findExistingItem(customerId, product.id, variant.id);

    if (existingItem) {
      const newQuantity = existingItem.quantity + requestedQuantity;
      if (newQuantity > availableStock) {
        throw new BadRequestException(
          `Adding ${requestedQuantity} items exceeds available stock. You already have ${existingItem.quantity} in cart (${availableStock} max available).`,
        );
      }
      await this.cartRepository.updateQuantity(existingItem.id, newQuantity);
    } else {
      await this.cartRepository.create({
        customerId,
        productId: product.id,
        productVariantId: variant.id,
        quantity: requestedQuantity,
      });
    }

    return this.getCart(customerId);
  }

  async updateQuantity(customerId: string, cartItemId: string, dto: UpdateCartItemDto) {
    const item = await this.cartRepository.findById(cartItemId);
    if (!item || item.customerId !== customerId) {
      throw new NotFoundException(`Cart item with ID "${cartItemId}" not found.`);
    }

    let targetQuantity = item.quantity;
    if (dto.action === CartUpdateAction.INCREASE) {
      targetQuantity += 1;
    } else if (dto.action === CartUpdateAction.DECREASE) {
      targetQuantity -= 1;
    } else if (dto.quantity !== undefined) {
      targetQuantity = dto.quantity;
    }

    if (targetQuantity <= 0) {
      await this.cartRepository.delete(cartItemId);
    } else {
      const variant = item.productVariant;
      const availableStock = variant ? (variant.stock ?? 0) : 0;
      if (targetQuantity > availableStock) {
        throw new BadRequestException(`Quantity (${targetQuantity}) cannot exceed available stock (${availableStock}).`);
      }
      await this.cartRepository.updateQuantity(cartItemId, targetQuantity);
    }

    return this.getCart(customerId);
  }

  async removeItem(customerId: string, cartItemId: string) {
    const item = await this.cartRepository.findById(cartItemId);
    if (!item || item.customerId !== customerId) {
      throw new NotFoundException(`Cart item with ID "${cartItemId}" not found.`);
    }

    await this.cartRepository.delete(cartItemId);
    return this.getCart(customerId);
  }

  async clearCart(customerId: string) {
    await this.cartRepository.clearCustomerCart(customerId);
    return this.getCart(customerId);
  }
}
