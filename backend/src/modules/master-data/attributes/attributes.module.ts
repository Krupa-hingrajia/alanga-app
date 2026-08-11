import { Module } from '@nestjs/common';
import { AttributesController } from './controllers/attributes.controller';
import { AttributesService } from './services/attributes.service';
import { IAttributesRepository } from './interfaces/attributes-repository.interface';
import { AttributesRepository } from './repositories/attributes.repository';

@Module({
  controllers: [AttributesController],
  providers: [
    AttributesService,
    {
      provide: IAttributesRepository,
      useClass: AttributesRepository,
    },
  ],
  exports: [AttributesService, IAttributesRepository],
})
export class AttributesModule {}
