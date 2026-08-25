import { ApiProperty } from '@nestjs/swagger';

export class ShippingResponseDto {
  @ApiProperty({ description: 'Shipping Configuration ID (UUID)', example: 'shp-123-uuid' })
  id: string;

  @ApiProperty({ description: 'Product ID (UUID)', example: 'prd-456-uuid' })
  productId: string;

  @ApiProperty({ description: 'Weight value', example: 0.5 })
  weight: number;

  @ApiProperty({ description: 'Weight unit (gm, kg)', example: 'kg' })
  weightUnit: string;

  @ApiProperty({ description: 'Package length', example: 20 })
  length: number;

  @ApiProperty({ description: 'Package width', example: 15 })
  width: number;

  @ApiProperty({ description: 'Package height', example: 10 })
  height: number;

  @ApiProperty({ description: 'Dimension unit (cm, inch)', example: 'cm' })
  dimensionUnit: string;

  @ApiProperty({ description: 'Shipping charge amount in INR', example: 50 })
  shippingCharge: number;

  @ApiProperty({ description: 'Whether free shipping is active', example: false })
  isFreeShipping: boolean;

  @ApiProperty({ description: 'Minimum order amount for free shipping', example: 499, nullable: true })
  freeShippingAboveAmount: number | null;

  @ApiProperty({ description: 'Minimum delivery days', example: 3 })
  estimatedDeliveryMinDays: number;

  @ApiProperty({ description: 'Maximum delivery days', example: 7 })
  estimatedDeliveryMaxDays: number;

  @ApiProperty({ description: 'Formatted delivery estimate label', example: '3-7 Days' })
  estimatedDeliveryLabel: string;

  @ApiProperty({ description: 'Whether Cash on Delivery is available', example: true })
  codAvailable: boolean;

  @ApiProperty({ description: 'Created timestamp', example: '2026-08-20T13:30:00.000Z' })
  createdAt: Date;

  @ApiProperty({ description: 'Updated timestamp', example: '2026-08-20T13:30:00.000Z' })
  updatedAt: Date;

  constructor(partial: Partial<ShippingResponseDto>) {
    Object.assign(this, partial);
  }
}
