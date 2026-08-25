import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { IWishlistRepository } from '../interfaces/wishlist-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { CreateWishlistDto } from '../dto/create-wishlist.dto';
import { WishlistResponseDto } from '../dto/wishlist-response.dto';
import { WishlistCheckResponseDto } from '../dto/wishlist-check-response.dto';
import { WishlistEntity } from '../entities/wishlist.entity';

@Injectable()
export class WishlistService {
  constructor(
    private readonly wishlistRepository: IWishlistRepository,
    private readonly prisma: PrismaService,
  ) {}

  private mapToResponseDto(entity: WishlistEntity): WishlistResponseDto {
    const product = entity.product || {};
    const variant = entity.productVariant || null;

    const sellingPrice = variant ? variant.price : (product.sellingPrice ?? 0);
    const mrp = product.mrp ?? sellingPrice;

    const discountPercentage = (mrp > sellingPrice && mrp > 0)
      ? Math.round(((mrp - sellingPrice) / mrp) * 100)
      : 0;

    const stock = variant ? (variant.currentStock ?? variant.stock ?? 0) : (product.stock ?? 0);
    let stockStatus = 'IN_STOCK';
    if (stock <= 0) {
      stockStatus = 'OUT_OF_STOCK';
    } else if (stock <= 5) {
      stockStatus = 'LOW_STOCK';
    }

    const shippingRaw = product.shipping || null;
    let shipping: any = null;

    if (shippingRaw) {
      const minDays = shippingRaw.estimatedDeliveryMinDays ?? 3;
      const maxDays = shippingRaw.estimatedDeliveryMaxDays ?? 7;
      shipping = {
        ...shippingRaw,
        estimatedDeliveryMinDays: minDays,
        estimatedDeliveryMaxDays: maxDays,
        estimatedDeliveryLabel: minDays === maxDays ? `${minDays} Days` : `${minDays}-${maxDays} Days`,
      };
    }

    return new WishlistResponseDto({
      id: entity.id,
      customerId: entity.customerId,
      productId: entity.productId,
      productVariantId: entity.productVariantId,
      product: {
        id: product.id,
        name: product.name,
        description: product.description,
        shortDescription: product.shortDescription,
        sku: product.sku,
        categoryId: product.categoryId,
        subCategoryId: product.subCategoryId,
        brandId: product.brandId,
        sellingPrice: product.sellingPrice,
        mrp: product.mrp,
        taxPercentage: product.taxPercentage,
        stock: product.stock,
        status: product.status,
        image: product.image,
        primaryImageUrl: product.productImages?.[0]?.imageUrl || product.image || '',
        images: product.productImages || [],
        variants: product.productVariants || [],
        shipping: shipping,
        brand: product.brand ? { id: product.brand.id, name: product.brand.name, logo: product.brand.logo } : null,
        category: product.category ? { id: product.category.id, name: product.category.name } : null,
      },
      selectedVariant: variant
        ? {
            id: variant.id,
            sku: variant.sku,
            variantName: variant.variantName,
            color: variant.color,
            size: variant.size,
            storage: variant.storage,
            price: variant.price,
            stock: variant.stock ?? variant.currentStock ?? 0,
            status: variant.status,
          }
        : null,
      sellingPrice,
      mrp,
      discountPercentage,
      stockStatus,
      shipping,
      brand: product.brand ? { id: product.brand.id, name: product.brand.name, logo: product.brand.logo } : null,
      category: product.category ? { id: product.category.id, name: product.category.name } : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    });
  }

  async toggleWishlist(customerId: string, dto: CreateWishlistDto) {
    // 1. Validate Product exists
    const product = await this.prisma.product.findFirst({
      where: { id: dto.productId, deletedAt: null },
    });
    if (!product) {
      throw new NotFoundException(`Product with ID "${dto.productId}" not found.`);
    }

    // 2. If ProductVariantId provided, validate it belongs to the Product
    if (dto.productVariantId) {
      const variant = await this.prisma.productVariant.findFirst({
        where: { id: dto.productVariantId, productId: dto.productId, deletedAt: null },
      });
      if (!variant) {
        throw new BadRequestException(
          `Product Variant with ID "${dto.productVariantId}" not found or does not belong to Product "${dto.productId}".`,
        );
      }
    }

    // 3. Enforce Business Rule: One Wishlist item per Product per Customer
    const existingProductWishlist = await this.wishlistRepository.findByCustomerAndProduct(customerId, dto.productId);

    if (existingProductWishlist) {
      const requestedVariantId = dto.productVariantId || null;
      const existingVariantId = existingProductWishlist.productVariantId || null;

      if (existingVariantId === requestedVariantId) {
        // Customer tapped same variant -> Untoggle / Remove from Wishlist
        await this.wishlistRepository.delete(existingProductWishlist.id);
        return {
          message: 'Product removed from Wishlist.',
          isWishlisted: false,
          wishlistId: null,
          productId: dto.productId,
          productVariantId: requestedVariantId,
        };
      } else {
        // Customer selected a DIFFERENT variant -> Update existing Wishlist item in place!
        const updated = await this.wishlistRepository.updateVariant(existingProductWishlist.id, requestedVariantId);
        return {
          message: 'Wishlist variant updated.',
          isWishlisted: true,
          wishlistId: updated.id,
          productId: dto.productId,
          productVariantId: requestedVariantId,
        };
      }
    } else {
      // Product not in Wishlist -> Add new entry
      const created = await this.wishlistRepository.create(customerId, dto.productId, dto.productVariantId);
      return {
        message: 'Product added to Wishlist.',
        isWishlisted: true,
        wishlistId: created.id,
        productId: dto.productId,
        productVariantId: dto.productVariantId || null,
      };
    }
  }

  async addToWishlist(customerId: string, dto: CreateWishlistDto): Promise<WishlistResponseDto> {
    const product = await this.prisma.product.findFirst({
      where: { id: dto.productId, deletedAt: null },
    });
    if (!product) {
      throw new NotFoundException(`Product with ID "${dto.productId}" not found.`);
    }

    if (dto.productVariantId) {
      const variant = await this.prisma.productVariant.findFirst({
        where: { id: dto.productVariantId, productId: dto.productId, deletedAt: null },
      });
      if (!variant) {
        throw new BadRequestException(
          `Product Variant with ID "${dto.productVariantId}" not found or does not belong to Product "${dto.productId}".`,
        );
      }
    }

    const existing = await this.wishlistRepository.findByCustomerAndProduct(customerId, dto.productId);
    if (existing) {
      if ((existing.productVariantId || null) !== (dto.productVariantId || null)) {
        const updated = await this.wishlistRepository.updateVariant(existing.id, dto.productVariantId || null);
        return this.mapToResponseDto(updated);
      }
      return this.mapToResponseDto(existing);
    }

    const created = await this.wishlistRepository.create(customerId, dto.productId, dto.productVariantId);
    return this.mapToResponseDto(created);
  }

  async getCustomerWishlist(customerId: string): Promise<WishlistResponseDto[]> {
    const items = await this.wishlistRepository.findByCustomer(customerId);
    return items.map((i) => this.mapToResponseDto(i));
  }

  async removeFromWishlist(customerId: string, wishlistId: string): Promise<{ success: boolean; message: string }> {
    const item = await this.wishlistRepository.findById(wishlistId);
    if (!item) {
      throw new NotFoundException(`Wishlist item with ID "${wishlistId}" not found.`);
    }

    if (item.customerId !== customerId) {
      throw new ForbiddenException('Forbidden. You do not own this wishlist item.');
    }

    await this.wishlistRepository.delete(wishlistId);
    return {
      success: true,
      message: 'Wishlist item removed successfully.',
    };
  }

  async checkWishlist(customerId: string, productId: string, productVariantId?: string): Promise<WishlistCheckResponseDto> {
    const item = await this.wishlistRepository.findByCustomerAndProduct(customerId, productId);
    if (item) {
      return new WishlistCheckResponseDto(true, item.id);
    }
    return new WishlistCheckResponseDto(false, null);
  }
}
