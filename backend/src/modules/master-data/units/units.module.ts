import { Module } from '@nestjs/common';
import { UnitsController } from './controllers/units.controller';
import { UnitsService } from './services/units.service';
import { IUnitsRepository } from './interfaces/units-repository.interface';
import { UnitsRepository } from './repositories/units.repository';

@Module({
  controllers: [UnitsController],
  providers: [
    UnitsService,
    {
      provide: IUnitsRepository,
      useClass: UnitsRepository,
    },
  ],
  exports: [UnitsService],
})
export class UnitsModule {}
