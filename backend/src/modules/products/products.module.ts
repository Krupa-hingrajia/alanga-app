import { Module } from '@nestjs/common';
import { AdminProductsController } from './controllers/admin-products.controller';
import { VendorProductsController } from './controllers/vendor-products.controller';
import { CustomerProductsController } from './controllers/customer-products.controller';
import { VendorProductImagesController } from './controllers/vendor-product-images.controller';
import { VendorProductVariantsController } from './controllers/vendor-product-variants.controller';
import { VendorInventoryController } from './controllers/vendor-inventory.controller';
import { VendorProductShippingController } from './controllers/vendor-product-shipping.controller';
import { ProductsService } from './services/products.service';
import { ProductImagesService } from './services/product-images.service';
import { ProductVariantsService } from './services/product-variants.service';
import { InventoryService } from './services/inventory.service';
import { ProductShippingService } from './services/product-shipping.service';
import { IProductsRepository } from './interfaces/products-repository.interface';
import { ProductsRepository } from './repositories/products.repository';
import { IProductImagesRepository } from './interfaces/product-images-repository.interface';
import { ProductImagesRepository } from './repositories/product-images.repository';
import { IProductVariantsRepository } from './interfaces/product-variants-repository.interface';
import { ProductVariantsRepository } from './repositories/product-variants.repository';
import { IInventoryRepository } from './interfaces/inventory-repository.interface';
import { InventoryRepository } from './repositories/inventory.repository';
import { IProductShippingRepository } from './interfaces/product-shipping-repository.interface';
import { ProductShippingRepository } from './repositories/product-shipping.repository';
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
    VendorProductImagesController,
    VendorProductVariantsController,
    VendorInventoryController,
    VendorProductShippingController,
  ],
  providers: [
    ProductsService,
    ProductImagesService,
    ProductVariantsService,
    InventoryService,
    ProductShippingService,
    {
      provide: IProductsRepository,
      useClass: ProductsRepository,
    },
    {
      provide: IProductImagesRepository,
      useClass: ProductImagesRepository,
    },
    {
      provide: IProductVariantsRepository,
      useClass: ProductVariantsRepository,
    },
    {
      provide: IInventoryRepository,
      useClass: InventoryRepository,
    },
    {
      provide: IProductShippingRepository,
      useClass: ProductShippingRepository,
    },
  ],
  exports: [
    ProductsService,
    ProductImagesService,
    ProductVariantsService,
    InventoryService,
    ProductShippingService,
    IProductsRepository,
    IProductImagesRepository,
    IProductVariantsRepository,
    IInventoryRepository,
    IProductShippingRepository,
  ],
})
export class ProductsModule {}
