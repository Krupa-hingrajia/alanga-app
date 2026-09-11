import { Module } from '@nestjs/common';
import { DatabaseModule } from '../../database/database.module';
import { AddressModule } from '../addresses/address.module';
import { CartModule } from '../cart/cart.module';
import { OrderRepository } from './repositories/order.repository';
import { CheckoutService } from './services/checkout.service';
import { OrderService } from './services/order.service';
import { CustomerCheckoutController } from './controllers/customer-checkout.controller';
import { CustomerOrderController } from './controllers/customer-order.controller';
import { VendorOrderController } from './controllers/vendor-order.controller';
import { AdminOrderController } from './controllers/admin-order.controller';

@Module({
  imports: [DatabaseModule, AddressModule, CartModule],
  controllers: [
    CustomerCheckoutController,
    CustomerOrderController,
    VendorOrderController,
    AdminOrderController,
  ],
  providers: [OrderRepository, CheckoutService, OrderService],
  exports: [OrderRepository, CheckoutService, OrderService],
})
export class OrderModule {}
