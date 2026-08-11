import { Injectable } from '@nestjs/common';
import { IAdminDashboardRepository } from '../interfaces/admin-dashboard-repository.interface';

@Injectable()
export class AdminDashboardService {
  constructor(private readonly dashboardRepository: IAdminDashboardRepository) {}

  async getSummary() {
    return this.dashboardRepository.getSummary();
  }
}
