import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export enum OrderStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  PROCESSING = 'PROCESSING',
  PACKED = 'PACKED',
  SHIPPED = 'SHIPPED',
  OUT_FOR_DELIVERY = 'OUT_FOR_DELIVERY',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
  RETURNED = 'RETURNED',
}

export class UpdateOrderStatusDto {
  @ApiProperty({
    description: 'New Order Status',
    example: 'CONFIRMED',
    enum: OrderStatus,
  })
  @IsEnum(OrderStatus)
  @IsNotEmpty()
  status: OrderStatus;

  @ApiPropertyOptional({
    description: 'Courier Partner name when shipping',
    example: 'Delhivery',
  })
  @IsOptional()
  @IsString()
  courierName?: string;

  @ApiPropertyOptional({
    description: 'AWB / Tracking Number',
    example: 'AWB123456789IN',
  })
  @IsOptional()
  @IsString()
  trackingNumber?: string;

  @ApiPropertyOptional({
    description: 'Public URL to track shipment',
    example: 'https://www.delhivery.com/track/package/AWB123456789IN',
  })
  @IsOptional()
  @IsString()
  trackingUrl?: string;

  @ApiPropertyOptional({
    description: 'Reason for cancellation if status is CANCELLED',
    example: 'Item out of stock',
  })
  @IsOptional()
  @IsString()
  cancelReason?: string;
}
