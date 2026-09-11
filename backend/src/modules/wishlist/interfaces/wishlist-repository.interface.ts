import { WishlistEntity } from '../entities/wishlist.entity';

export abstract class IWishlistRepository {
  abstract findByCustomer(customerId: string): Promise<WishlistEntity[]>;
  abstract findExisting(customerId: string, productId: string, productVariantId: string): Promise<WishlistEntity | null>;
  abstract findByCustomerAndProduct(customerId: string, productId: string): Promise<WishlistEntity | null>;
  abstract findById(id: string): Promise<WishlistEntity | null>;
  abstract create(customerId: string, productId: string, productVariantId: string): Promise<WishlistEntity>;
  abstract updateVariant(id: string, productVariantId: string): Promise<WishlistEntity>;
  abstract delete(id: string): Promise<void>;
}
