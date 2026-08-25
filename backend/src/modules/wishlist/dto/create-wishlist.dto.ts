import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsOptional, IsUUID } from 'class-validator';

export class CreateWishlistDto {
  @ApiProperty({ description: 'Product ID (UUID)', example: 'f93332ae-35de-42fe-81a0-57ad33647f47' })
  @IsNotEmpty({ message: 'Product ID is required.' })
  @IsString()
  @IsUUID('4', { message: 'Product ID must be a valid UUID.' })
  productId: string;

  @ApiPropertyOptional({ description: 'Product Variant ID (UUID)', example: '1e3df24a-d65b-4cb0-b54b-2c876eb317d9', nullable: true })
  @IsOptional()
  @IsString()
  @IsUUID('4', { message: 'Product Variant ID must be a valid UUID.' })
  productVariantId?: string;
}
