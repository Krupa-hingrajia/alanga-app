import { Module } from '@nestjs/common';
import { AdminProductsController } from './controllers/admin-products.controller';
import { VendorProductsController } from './controllers/vendor-products.controller';
import { CustomerProductsController } from './controllers/customer-products.controller';
import { ProductsService } from './services/products.service';
import { IProductsRepository } from './interfaces/products-repository.interface';
import { ProductsRepository } from './repositories/products.repository';

@Module({
  controllers: [
    AdminProductsController,
    VendorProductsController,
    CustomerProductsController,
  ],
  providers: [
    ProductsService,
    {
      provide: IProductsRepository,
      useClass: ProductsRepository,
    },
  ],
  exports: [ProductsService, IProductsRepository],
})
export class ProductsModule {}
