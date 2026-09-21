import { Controller, Get, Put, Body, Param, UseGuards, HttpStatus, Logger } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { OrderService } from '../services/order.service';
import { UpdateOrderStatusDto } from '../dto/update-order-status.dto';

@ApiTags('Vendor Orders')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/orders')
export class VendorOrderController {
  private readonly logger = new Logger(VendorOrderController.name);

  constructor(private readonly orderService: OrderService) {}

  @Get()
  @ApiOperation({ summary: 'Get orders containing vendor products' })
  @ApiResponse({ status: 200, description: 'Vendor orders retrieved successfully.' })
  async getVendorOrders(@CurrentUser('id') vendorId: string) {
    this.logger.log(`[VendorOrderController] GET /vendor/orders called by vendor: ${vendorId}`);
    const data = await this.orderService.getVendorOrders(vendorId);
    return {
      success: true,
      message: 'Vendor orders retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/status')
  @ApiOperation({ summary: 'Update status for vendor items in order (CONFIRMED, PROCESSING, PACKED, SHIPPED, OUT_FOR_DELIVERY, DELIVERED)' })
  @ApiParam({ name: 'id', description: 'Order UUID' })
  @ApiResponse({ status: 200, description: 'Order status updated successfully.' })
  @ApiResponse({ status: 403, description: 'Vendor does not own products in this order.' })
  @ApiResponse({ status: 404, description: 'Order not found.' })
  async updateVendorOrderStatus(
    @Param('id') id: string,
    @Body() dto: UpdateOrderStatusDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.orderService.updateVendorOrderStatus(vendorId, id, dto);
    return {
      success: true,
      message: `Order status updated to ${dto.status} successfully`,
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
