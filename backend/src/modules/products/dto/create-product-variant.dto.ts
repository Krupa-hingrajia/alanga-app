import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsNumber, IsInt, Min, IsOptional, IsBoolean } from 'class-validator';

export class CreateProductVariantDto {
  @ApiProperty({
    description: 'Variant name (e.g. "Black / XL" or "128 GB Storage")',
    example: 'Black / XL',
  })
  @IsNotEmpty()
  @IsString()
  variantName: string;

  @ApiProperty({
    description: 'Unique Stock Keeping Unit (SKU) for this variant',
    example: 'TSHIRT-BLK-XL-001',
  })
  @IsNotEmpty()
  @IsString()
  sku: string;

  @ApiProperty({
    description: 'Price of the product variant (cannot be negative)',
    example: 999.0,
    minimum: 0,
  })
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  price: number;

  @ApiProperty({
    description: 'Available stock quantity for this variant (cannot be negative)',
    example: 50,
    minimum: 0,
  })
  @IsNotEmpty()
  @IsInt()
  @Min(0)
  stock: number;

  @ApiPropertyOptional({
    description: 'Color of the variant (optional)',
    example: 'Black',
  })
  @IsOptional()
  @IsString()
  color?: string;

  @ApiPropertyOptional({
    description: 'Size of the variant (optional)',
    example: 'XL',
  })
  @IsOptional()
  @IsString()
  size?: string;

  @ApiPropertyOptional({
    description: 'Storage capacity of the variant (optional)',
    example: '128 GB',
  })
  @IsOptional()
  @IsString()
  storage?: string;

  @ApiPropertyOptional({
    description: 'Status of the variant (default: ACTIVE)',
    example: 'ACTIVE',
    default: 'ACTIVE',
  })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({
    description: 'Whether this variant is marked as default',
    example: false,
    default: false,
  })
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;
}
