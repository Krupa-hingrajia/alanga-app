import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';

export enum PaymentMethod {
  COD = 'COD',
  RAZORPAY = 'RAZORPAY',
  STRIPE = 'STRIPE',
}

export class PlaceOrderDto {
  @ApiProperty({ description: 'Selected shipping address UUID', example: 'addr-uuid-123' })
  @IsString()
  @IsNotEmpty()
  addressId: string;

  @ApiProperty({ description: 'Payment method (COD / RAZORPAY / STRIPE)', example: 'COD', enum: PaymentMethod, default: 'COD' })
  @IsEnum(PaymentMethod)
  @IsOptional()
  paymentMethod?: PaymentMethod = PaymentMethod.COD;

  @ApiPropertyOptional({ description: 'Delivery notes / instructions', example: 'Leave at front door' })
  @IsString()
  @IsOptional()
  notes?: string;
}
