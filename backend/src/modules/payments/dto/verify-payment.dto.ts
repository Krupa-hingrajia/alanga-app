import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { PaymentGateway } from './create-payment-order.dto';

export class VerifyPaymentDto {
  @ApiProperty({
    description: 'Payment gateway provider used',
    enum: PaymentGateway,
    example: PaymentGateway.RAZORPAY,
  })
  @IsEnum(PaymentGateway)
  @IsNotEmpty()
  gateway: PaymentGateway;

  @ApiProperty({
    description: 'Gateway Order ID',
    example: 'order_Ek123456789',
  })
  @IsString()
  @IsNotEmpty()
  gatewayOrderId: string;

  @ApiPropertyOptional({
    description: 'Gateway Payment ID / Transaction ID',
    example: 'pay_Ek123456789',
  })
  @IsString()
  @IsOptional()
  gatewayPaymentId?: string;

  @ApiPropertyOptional({
    description: 'Gateway Signature for verification (required for Razorpay)',
    example: '9ef87b0a...',
  })
  @IsString()
  @IsOptional()
  gatewaySignature?: string;

  @ApiProperty({
    description: 'Selected shipping address UUID',
    example: 'addr-uuid-123',
  })
  @IsString()
  @IsNotEmpty()
  addressId: string;

  @ApiPropertyOptional({
    description: 'Optional order notes',
    example: 'Leave at front desk',
  })
  @IsString()
  @IsOptional()
  notes?: string;
}
