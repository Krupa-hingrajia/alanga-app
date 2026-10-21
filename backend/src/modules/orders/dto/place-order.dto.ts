import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';

export enum PaymentMethod {
  COD = 'COD',
  RAZORPAY = 'RAZORPAY',
  CASHFREE = 'CASHFREE',
  STRIPE = 'STRIPE',
}

export class PlaceOrderDto {
  @ApiProperty({ description: 'Selected shipping address UUID', example: 'addr-uuid-123' })
  @IsString()
  @IsNotEmpty()
  addressId: string;

  @ApiProperty({ description: 'Payment method (COD / RAZORPAY / CASHFREE)', example: 'COD', enum: PaymentMethod, default: 'COD' })
  @IsEnum(PaymentMethod)
  @IsOptional()
  paymentMethod?: PaymentMethod = PaymentMethod.COD;

  @ApiPropertyOptional({ description: 'Delivery notes / instructions', example: 'Leave at front door' })
  @IsString()
  @IsOptional()
  notes?: string;

  @ApiPropertyOptional({ description: 'Gateway Order ID (Razorpay or Cashfree)', example: 'order_123456' })
  @IsString()
  @IsOptional()
  gatewayOrderId?: string;

  @ApiPropertyOptional({ description: 'Gateway Payment ID / Transaction ID', example: 'pay_123456' })
  @IsString()
  @IsOptional()
  gatewayPaymentId?: string;

  @ApiPropertyOptional({ description: 'Gateway Signature for verification', example: 'sig_abc123' })
  @IsString()
  @IsOptional()
  gatewaySignature?: string;
}
