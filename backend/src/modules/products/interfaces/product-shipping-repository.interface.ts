import { ProductShippingEntity } from '../entities/product-shipping.entity';

export abstract class IProductShippingRepository {
  abstract findByProductId(productId: string): Promise<ProductShippingEntity | null>;
  abstract create(productId: string, data: any): Promise<ProductShippingEntity>;
  abstract update(productId: string, data: any): Promise<ProductShippingEntity>;
  abstract upsert(productId: string, data: any): Promise<ProductShippingEntity>;
}
