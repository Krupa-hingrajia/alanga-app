import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { PaymentsService } from './payments.service';
import { CreatePaymentOrderDto } from './dto/create-payment-order.dto';
import { VerifyPaymentDto } from './dto/verify-payment.dto';

@ApiTags('Payments')
@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Get('config')
  @ApiOperation({ summary: 'Get public gateway configuration (Public Key ID & Environment)' })
  @ApiResponse({ status: 200, description: 'Public payment config retrieved.' })
  getPaymentConfig() {
    return {
      success: true,
      data: this.paymentsService.getPaymentConfig(),
      statusCode: HttpStatus.OK,
    };
  }

  @Post('create-order')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CUSTOMER', 'VENDOR', 'ADMIN')
  @ApiOperation({ summary: 'Initialize a payment order with Razorpay or Cashfree' })
  @ApiResponse({ status: 201, description: 'Payment order created.' })
  @ApiResponse({ status: 400, description: 'Cart empty or out of stock.' })
  async createPaymentOrder(
    @CurrentUser('id') customerId: string,
    @Body() dto: CreatePaymentOrderDto,
  ) {
    const data = await this.paymentsService.createPaymentOrder(customerId, dto);
    return {
      success: true,
      message: 'Payment order created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Post('verify')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('CUSTOMER', 'VENDOR', 'ADMIN')
  @ApiOperation({ summary: 'Verify payment signature/status and place confirmed order' })
  @ApiResponse({ status: 201, description: 'Payment verified and order placed.' })
  @ApiResponse({ status: 400, description: 'Invalid signature or payment failed.' })
  async verifyPayment(
    @CurrentUser('id') customerId: string,
    @Body() dto: VerifyPaymentDto,
  ) {
    const data = await this.paymentsService.verifyAndPlaceOrder(customerId, dto);
    return {
      success: true,
      message: 'Payment verified and order placed successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }
}
