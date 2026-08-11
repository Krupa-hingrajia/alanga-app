import { Module } from '@nestjs/common';
import { VendorDashboardController } from './controllers/vendor-dashboard.controller';
import { VendorDashboardService } from './services/vendor-dashboard.service';
import { IVendorDashboardRepository } from './interfaces/vendor-dashboard-repository.interface';
import { VendorDashboardRepository } from './repositories/vendor-dashboard.repository';

@Module({
  controllers: [VendorDashboardController],
  providers: [
    VendorDashboardService,
    {
      provide: IVendorDashboardRepository,
      useClass: VendorDashboardRepository,
    },
  ],
})
export class VendorDashboardModule {}
