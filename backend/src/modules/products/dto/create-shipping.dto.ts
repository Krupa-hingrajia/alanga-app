import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNumber, Min, IsOptional, IsString, IsBoolean, IsIn, IsInt } from 'class-validator';

export class CreateShippingDto {
  @ApiPropertyOptional({ description: 'Package weight (must be >= 0)', example: 0.5, default: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0, { message: 'Weight cannot be negative.' })
  weight?: number;

  @ApiPropertyOptional({ description: 'Weight unit (gm, kg)', example: 'kg', enum: ['gm', 'kg'], default: 'kg' })
  @IsOptional()
  @IsString()
  @IsIn(['gm', 'kg'], { message: 'Weight unit must be gm or kg.' })
  weightUnit?: string;

  @ApiPropertyOptional({ description: 'Package length (must be >= 0)', example: 20, default: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0, { message: 'Length cannot be negative.' })
  length?: number;

  @ApiPropertyOptional({ description: 'Package width (must be >= 0)', example: 15, default: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0, { message: 'Width cannot be negative.' })
  width?: number;

  @ApiPropertyOptional({ description: 'Package height (must be >= 0)', example: 10, default: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0, { message: 'Height cannot be negative.' })
  height?: number;

  @ApiPropertyOptional({ description: 'Dimension unit (cm, inch)', example: 'cm', enum: ['cm', 'inch'], default: 'cm' })
  @IsOptional()
  @IsString()
  @IsIn(['cm', 'inch'], { message: 'Dimension unit must be cm or inch.' })
  dimensionUnit?: string;

  @ApiPropertyOptional({ description: 'Shipping charge amount (must be >= 0)', example: 50, default: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0, { message: 'Shipping charge cannot be negative.' })
  shippingCharge?: number;

  @ApiPropertyOptional({ description: 'Whether free shipping is offered for this product', example: false, default: false })
  @IsOptional()
  @IsBoolean()
  isFreeShipping?: boolean;

  @ApiPropertyOptional({ description: 'Minimum cart total required for free shipping', example: 499, nullable: true })
  @IsOptional()
  @IsNumber()
  @Min(0, { message: 'Free shipping threshold amount cannot be negative.' })
  freeShippingAboveAmount?: number;

  @ApiPropertyOptional({ description: 'Minimum estimated delivery days (must be >= 1)', example: 3, default: 3 })
  @IsOptional()
  @IsInt()
  @Min(1, { message: 'Minimum delivery days must be at least 1.' })
  estimatedDeliveryMinDays?: number;

  @ApiPropertyOptional({ description: 'Maximum estimated delivery days (must be >= min days)', example: 7, default: 7 })
  @IsOptional()
  @IsInt()
  @Min(1, { message: 'Maximum delivery days must be at least 1.' })
  estimatedDeliveryMaxDays?: number;

  @ApiPropertyOptional({ description: 'Whether Cash on Delivery (COD) is available', example: true, default: true })
  @IsOptional()
  @IsBoolean()
  codAvailable?: boolean;
}
