import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export enum PaymentGateway {
  RAZORPAY = 'RAZORPAY',
  CASHFREE = 'CASHFREE',
}

export class CreatePaymentOrderDto {
  @ApiProperty({
    description: 'Payment gateway provider',
    enum: PaymentGateway,
    example: PaymentGateway.RAZORPAY,
  })
  @IsEnum(PaymentGateway)
  @IsNotEmpty()
  gateway: PaymentGateway;

  @ApiProperty({
    description: 'Selected shipping address UUID',
    example: 'addr-uuid-123',
  })
  @IsString()
  @IsNotEmpty()
  addressId: string;

  @ApiPropertyOptional({
    description: 'Optional order notes',
    example: 'Leave at reception',
  })
  @IsString()
  @IsOptional()
  notes?: string;
}
