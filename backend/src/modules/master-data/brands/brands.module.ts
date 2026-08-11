import { Module } from '@nestjs/common';
import { BrandsController } from './controllers/brands.controller';
import { BrandsService } from './services/brands.service';
import { IBrandsRepository } from './interfaces/brands-repository.interface';
import { BrandsRepository } from './repositories/brands.repository';

@Module({
  controllers: [BrandsController],
  providers: [
    BrandsService,
    {
      provide: IBrandsRepository,
      useClass: BrandsRepository,
    },
  ],
  exports: [BrandsService],
})
export class BrandsModule {}
