import { Controller, Get, UseGuards, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { CheckoutService } from '../services/checkout.service';

@ApiTags('Customer Checkout')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('CUSTOMER')
@Controller('customer/checkout')
export class CustomerCheckoutController {
  constructor(private readonly checkoutService: CheckoutService) {}

  @Get()
  @ApiOperation({ summary: 'Get checkout summary (Cart items, Shipping, Grand Total, Default Address, Delivery range)' })
  @ApiResponse({ status: 200, description: 'Checkout summary retrieved successfully.' })
  @ApiResponse({ status: 400, description: 'Shopping cart is empty.' })
  async getCheckoutSummary(@CurrentUser('id') customerId: string) {
    const data = await this.checkoutService.getCheckoutSummary(customerId);
    return {
      success: true,
      message: 'Checkout summary retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
