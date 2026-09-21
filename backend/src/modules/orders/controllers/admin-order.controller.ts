import { Controller, Get, Put, Body, Param, Query, UseGuards, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { OrderService } from '../services/order.service';
import { UpdateOrderStatusDto } from '../dto/update-order-status.dto';
import { AdminOrderQueryDto } from '../dto/admin-order-query.dto';

@ApiTags('Admin Orders')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/orders')
export class AdminOrderController {
  constructor(private readonly orderService: OrderService) {}

  @Get()
  @ApiOperation({ summary: 'Get all marketplace orders with filtering by vendor, customer, status, date range' })
  @ApiResponse({ status: 200, description: 'Marketplace orders retrieved successfully.' })
  async getAdminOrders(@Query() query: AdminOrderQueryDto) {
    const data = await this.orderService.getAdminOrders(query);
    return {
      success: true,
      message: 'Admin orders retrieved successfully',
      data: data.items,
      meta: {
        total: data.total,
        page: data.page,
        limit: data.limit,
      },
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get detailed order information by ID' })
  @ApiParam({ name: 'id', description: 'Order UUID' })
  @ApiResponse({ status: 200, description: 'Order details retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'Order not found.' })
  async getAdminOrderById(@Param('id') id: string) {
    const data = await this.orderService.getAdminOrderById(id);
    return {
      success: true,
      message: 'Order details retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/status')
  @ApiOperation({ summary: 'Override order status (Admin master control)' })
  @ApiParam({ name: 'id', description: 'Order UUID' })
  @ApiResponse({ status: 200, description: 'Order status updated successfully.' })
  @ApiResponse({ status: 404, description: 'Order not found.' })
  async updateAdminOrderStatus(
    @Param('id') id: string,
    @Body() dto: UpdateOrderStatusDto,
  ) {
    const data = await this.orderService.updateAdminOrderStatus(id, dto);
    return {
      success: true,
      message: `Order status updated to ${dto.status} successfully`,
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
