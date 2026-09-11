import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsInt, Min, IsOptional } from 'class-validator';

export class AddToCartDto {
  @ApiProperty({ description: 'ID of the product', example: 'prod-uuid-123' })
  @IsString()
  @IsNotEmpty()
  productId: string;

  @ApiPropertyOptional({ description: 'ID of the selected variant', example: 'var-uuid-456' })
  @IsString()
  @IsOptional()
  variantId?: string;

  @ApiPropertyOptional({ description: 'Alias for variantId', example: 'var-uuid-456' })
  @IsString()
  @IsOptional()
  productVariantId?: string;

  @ApiProperty({ description: 'Quantity to add to cart', example: 1, default: 1 })
  @IsInt()
  @Min(1)
  quantity: number = 1;
}
