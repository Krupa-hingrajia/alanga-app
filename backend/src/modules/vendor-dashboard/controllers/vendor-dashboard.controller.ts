import { Controller, Get, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { VendorDashboardService } from '../services/vendor-dashboard.service';
import { SalesQueryDto } from '../dto/sales-query.dto';
import { RecentOrdersQueryDto } from '../dto/recent-orders-query.dto';
import { LowStockQueryDto } from '../dto/low-stock-query.dto';

@ApiTags('Vendor Dashboard')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/dashboard')
export class VendorDashboardController {
  constructor(private readonly dashboardService: VendorDashboardService) {}

  @Get('summary')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get vendor dashboard summary statistics' })
  @ApiResponse({ status: 200, description: 'Summary data retrieved successfully.' })
  @ApiResponse({ status: 401, description: 'Unauthorized.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor role required.' })
  async getSummary(@CurrentUser('id') vendorId: string) {
    const data = await this.dashboardService.getSummary(vendorId);
    return {
      success: true,
      message: 'Dashboard summary retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('sales-overview')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get vendor sales overview (daily, weekly, monthly trends)' })
  @ApiResponse({ status: 200, description: 'Sales overview retrieved successfully.' })
  @ApiResponse({ status: 401, description: 'Unauthorized.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor role required.' })
  async getSalesOverview(
    @CurrentUser('id') vendorId: string,
    @Query() query: SalesQueryDto,
  ) {
    const data = await this.dashboardService.getSalesOverview(vendorId, query.startDate, query.endDate);
    return {
      success: true,
      message: 'Sales overview retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('recent-orders')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get latest vendor orders with pagination' })
  @ApiResponse({ status: 200, description: 'Recent orders retrieved successfully.' })
  @ApiResponse({ status: 401, description: 'Unauthorized.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor role required.' })
  async getRecentOrders(
    @CurrentUser('id') vendorId: string,
    @Query() query: RecentOrdersQueryDto,
  ) {
    const data = await this.dashboardService.getRecentOrders(vendorId, query.limit || 10, query.offset || 0);
    return {
      success: true,
      message: 'Recent orders retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('low-stock')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get vendor products with stock below threshold limit' })
  @ApiResponse({ status: 200, description: 'Low stock products retrieved successfully.' })
  @ApiResponse({ status: 401, description: 'Unauthorized.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor role required.' })
  async getLowStockProducts(
    @CurrentUser('id') vendorId: string,
    @Query() query: LowStockQueryDto,
  ) {
    const data = await this.dashboardService.getLowStockProducts(vendorId, query.threshold || 10);
    return {
      success: true,
      message: 'Low stock products retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
