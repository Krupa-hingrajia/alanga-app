import { Module } from '@nestjs/common';
import { AdminDashboardController } from './controllers/admin-dashboard.controller';
import { AdminDashboardService } from './services/admin-dashboard.service';
import { IAdminDashboardRepository } from './interfaces/admin-dashboard-repository.interface';
import { AdminDashboardRepository } from './repositories/admin-dashboard.repository';

@Module({
  controllers: [AdminDashboardController],
  providers: [
    AdminDashboardService,
    {
      provide: IAdminDashboardRepository,
      useClass: AdminDashboardRepository,
    },
  ],
})
export class AdminDashboardModule {}
