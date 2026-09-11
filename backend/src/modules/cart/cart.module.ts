import { Module } from '@nestjs/common';
import { CustomerCartController } from './controllers/customer-cart.controller';
import { CartService } from './services/cart.service';
import { ICartRepository } from './interfaces/cart-repository.interface';
import { CartRepository } from './repositories/cart.repository';

@Module({
  controllers: [CustomerCartController],
  providers: [
    CartService,
    CartRepository,
    {
      provide: ICartRepository,
      useClass: CartRepository,
    },
  ],
  exports: [CartService, CartRepository, ICartRepository],
})
export class CartModule {}
