import { Module } from '@nestjs/common';
import { AttributeValuesController } from './controllers/attribute-values.controller';
import { AttributeValuesService } from './services/attribute-values.service';
import { IAttributeValuesRepository } from './interfaces/attribute-values-repository.interface';
import { AttributeValuesRepository } from './repositories/attribute-values.repository';
import { AttributesModule } from '../attributes/attributes.module';

@Module({
  imports: [AttributesModule],
  controllers: [AttributeValuesController],
  providers: [
    AttributeValuesService,
    {
      provide: IAttributeValuesRepository,
      useClass: AttributeValuesRepository,
    },
  ],
  exports: [AttributeValuesService],
})
export class AttributeValuesModule {}
