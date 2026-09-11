import { Controller, Get, Post, Body, Param, UseGuards, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { OrderService } from '../services/order.service';
import { PlaceOrderDto } from '../dto/place-order.dto';

@ApiTags('Customer Orders')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('CUSTOMER')
@Controller('customer/orders')
export class CustomerOrderController {
  constructor(private readonly orderService: OrderService) {}

  @Post()
  @ApiOperation({ summary: 'Place an order using current shopping cart and selected address' })
  @ApiResponse({ status: 201, description: 'Order placed successfully.' })
  @ApiResponse({ status: 400, description: 'Cart empty, address invalid, or stock unavailable.' })
  async placeOrder(
    @Body() dto: PlaceOrderDto,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.orderService.placeOrder(customerId, dto);
    return {
      success: true,
      message: 'Order placed successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @ApiOperation({ summary: 'Get all orders placed by current customer' })
  @ApiResponse({ status: 200, description: 'Customer orders retrieved successfully.' })
  async getOrders(@CurrentUser('id') customerId: string) {
    const data = await this.orderService.getCustomerOrders(customerId);
    return {
      success: true,
      message: 'Orders retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get detailed order information by Order ID' })
  @ApiParam({ name: 'id', description: 'Order UUID' })
  @ApiResponse({ status: 200, description: 'Order details retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'Order not found.' })
  async getOrderById(
    @Param('id') id: string,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.orderService.getCustomerOrderById(customerId, id);
    return {
      success: true,
      message: 'Order details retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
