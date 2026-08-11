import { Module } from '@nestjs/common';
import { AdminProductsController } from './controllers/admin-products.controller';
import { VendorProductsController } from './controllers/vendor-products.controller';
import { CustomerProductsController } from './controllers/customer-products.controller';
import { ProductsService } from './services/products.service';
import { IProductsRepository } from './interfaces/products-repository.interface';
import { ProductsRepository } from './repositories/products.repository';
import { CategoriesModule } from '../master-data/categories/categories.module';
import { SubCategoriesModule } from '../master-data/sub-categories/sub-categories.module';
import { BrandsModule } from '../master-data/brands/brands.module';

@Module({
  imports: [
    CategoriesModule,
    SubCategoriesModule,
    BrandsModule,
  ],
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
