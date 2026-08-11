import { Module } from '@nestjs/common';
import { SubCategoriesController } from './controllers/sub-categories.controller';
import { VendorSubCategoriesController } from './controllers/vendor-sub-categories.controller';
import { CustomerSubCategoriesController } from './controllers/customer-sub-categories.controller';
import { SubCategoriesService } from './services/sub-categories.service';
import { ISubCategoriesRepository } from './interfaces/sub-categories-repository.interface';
import { SubCategoriesRepository } from './repositories/sub-categories.repository';
import { CategoriesModule } from '../categories/categories.module';

@Module({
  imports: [CategoriesModule],
  controllers: [
    SubCategoriesController,
    VendorSubCategoriesController,
    CustomerSubCategoriesController,
  ],
  providers: [
    SubCategoriesService,
    {
      provide: ISubCategoriesRepository,
      useClass: SubCategoriesRepository,
    },
  ],
  exports: [SubCategoriesService, ISubCategoriesRepository],
})
export class SubCategoriesModule {}
