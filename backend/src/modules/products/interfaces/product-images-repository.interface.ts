import { ProductImageEntity } from '../entities/product-image.entity';

export abstract class IProductImagesRepository {
  abstract createMany(
    productId: string,
    images: Array<{ imageUrl: string; isPrimary: boolean; displayOrder: number; productVariantId?: string | null }>,
    productVariantId?: string,
  ): Promise<ProductImageEntity[]>;

  abstract findByProductId(productId: string, productVariantId?: string): Promise<ProductImageEntity[]>;
  abstract findById(id: string): Promise<ProductImageEntity | null>;
  abstract countActiveByProductId(productId: string, productVariantId?: string): Promise<number>;
  abstract getMaxDisplayOrder(productId: string, productVariantId?: string): Promise<number>;
  abstract setPrimaryImage(productId: string, imageId: string, productVariantId?: string): Promise<ProductImageEntity>;
  abstract softDelete(imageId: string): Promise<ProductImageEntity>;
  abstract findFirstAvailable(productId: string, productVariantId?: string): Promise<ProductImageEntity | null>;
  abstract updateDisplayOrders(
    productId: string,
    orders: Array<{ id: string; displayOrder: number }>,
  ): Promise<ProductImageEntity[]>;
}
