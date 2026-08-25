import { Wishlist } from '@prisma/client';

export class WishlistEntity implements Wishlist {
  id: string;
  customerId: string;
  productId: string;
  productVariantId: string | null;
  createdAt: Date;
  updatedAt: Date;

  product?: any;
  productVariant?: any;

  constructor(partial: Partial<WishlistEntity>) {
    Object.assign(this, partial);
  }
}
