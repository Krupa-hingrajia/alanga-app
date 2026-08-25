import { Module } from '@nestjs/common';
import { CustomerWishlistController } from './controllers/customer-wishlist.controller';
import { WishlistService } from './services/wishlist.service';
import { IWishlistRepository } from './interfaces/wishlist-repository.interface';
import { WishlistRepository } from './repositories/wishlist.repository';

@Module({
  controllers: [CustomerWishlistController],
  providers: [
    WishlistService,
    {
      provide: IWishlistRepository,
      useClass: WishlistRepository,
    },
  ],
  exports: [WishlistService, IWishlistRepository],
})
export class WishlistModule {}
