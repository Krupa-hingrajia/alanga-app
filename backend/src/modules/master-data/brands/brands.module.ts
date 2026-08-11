import { Module } from '@nestjs/common';
import { BrandsController } from './controllers/brands.controller';
import { VendorBrandsController } from './controllers/vendor-brands.controller';
import { CustomerBrandsController } from './controllers/customer-brands.controller';
import { BrandsService } from './services/brands.service';
import { IBrandsRepository } from './interfaces/brands-repository.interface';
import { BrandsRepository } from './repositories/brands.repository';

@Module({
  controllers: [
    BrandsController,
    VendorBrandsController,
    CustomerBrandsController,
  ],
  providers: [
    BrandsService,
    {
      provide: IBrandsRepository,
      useClass: BrandsRepository,
    },
  ],
  exports: [BrandsService, IBrandsRepository],
})
export class BrandsModule {}
