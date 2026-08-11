import { Controller, Get, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { AdminDashboardService } from '../services/admin-dashboard.service';

@ApiTags('Admin Dashboard')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/dashboard')
export class AdminDashboardController {
  constructor(private readonly dashboardService: AdminDashboardService) {}

  @Get('summary')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get admin dashboard summary statistics' })
  @ApiResponse({ status: 200, description: 'Summary data retrieved successfully.' })
  @ApiResponse({ status: 401, description: 'Unauthorized.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Admin role required.' })
  async getSummary() {
    const data = await this.dashboardService.getSummary();
    return {
      success: true,
      message: 'Admin dashboard summary retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
