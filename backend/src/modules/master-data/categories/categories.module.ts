import { Module } from '@nestjs/common';
import { CategoriesController } from './controllers/categories.controller';
import { CategoriesService } from './services/categories.service';
import { ICategoriesRepository } from './interfaces/categories-repository.interface';
import { CategoriesRepository } from './repositories/categories.repository';

@Module({
  controllers: [CategoriesController],
  providers: [
    CategoriesService,
    {
      provide: ICategoriesRepository,
      useClass: CategoriesRepository,
    },
  ],
  exports: [CategoriesService],
})
export class CategoriesModule {}
