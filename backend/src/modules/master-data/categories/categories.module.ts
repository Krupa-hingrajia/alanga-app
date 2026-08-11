import { Module } from '@nestjs/common';
import { CategoriesController } from './controllers/categories.controller';
import { VendorCategoriesController } from './controllers/vendor-categories.controller';
import { CustomerCategoriesController } from './controllers/customer-categories.controller';
import { CategoriesService } from './services/categories.service';
import { ICategoriesRepository } from './interfaces/categories-repository.interface';
import { CategoriesRepository } from './repositories/categories.repository';

@Module({
  controllers: [
    CategoriesController,
    VendorCategoriesController,
    CustomerCategoriesController,
  ],
  providers: [
    CategoriesService,
    {
      provide: ICategoriesRepository,
      useClass: CategoriesRepository,
    },
  ],
  exports: [CategoriesService, ICategoriesRepository],
})
export class CategoriesModule {}
