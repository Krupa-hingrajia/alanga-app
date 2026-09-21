import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsUUID,
  IsInt,
  Min,
  Max,
  IsOptional,
  IsArray,
  MinLength,
} from 'class-validator';

export class CreateReviewDto {
  @ApiProperty({
    description: 'Product UUID to be reviewed',
    example: 'a2f7055a-f691-453e-a5dc-2f4ba94a517a',
  })
  @IsUUID('4', { message: 'productId must be a valid UUID' })
  productId: string;

  @ApiProperty({
    description: 'Delivered Order UUID in which the product was purchased',
    example: 'cb5b8260-52ee-42f9-9aef-ac834d35dafb',
  })
  @IsUUID('4', { message: 'orderId must be a valid UUID' })
  orderId: string;

  @ApiPropertyOptional({
    description: 'Product Variant UUID (optional)',
    example: 'd3542e22-5523-473f-82e1-c271c563f6b3',
  })
  @IsOptional()
  @IsUUID('4', { message: 'variantId must be a valid UUID' })
  variantId?: string;

  @ApiPropertyOptional({
    description: 'Product Variant UUID alias (optional)',
    example: 'd3542e22-5523-473f-82e1-c271c563f6b3',
  })
  @IsOptional()
  @IsUUID('4', { message: 'productVariantId must be a valid UUID' })
  productVariantId?: string;

  @ApiProperty({
    description: 'Rating score between 1 and 5',
    example: 5,
    minimum: 1,
    maximum: 5,
  })
  @IsInt({ message: 'Rating must be an integer' })
  @Min(1, { message: 'Rating must be at least 1' })
  @Max(5, { message: 'Rating cannot exceed 5' })
  rating: number;

  @ApiPropertyOptional({
    description: 'Short headline or title of the review',
    example: 'Excellent quality and perfect fit!',
  })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({
    description: 'Detailed review feedback and customer experience (minimum 10 characters)',
    example: 'Fabric is very soft and comfortable. Delivery was prompt. Highly recommend!',
  })
  @IsOptional()
  @IsString()
  @MinLength(10, { message: 'Review must be at least 10 characters long' })
  review?: string;

  @ApiPropertyOptional({
    description: 'Detailed review description (backward compatibility alias for review, minimum 10 characters)',
    example: 'Fabric is very soft and comfortable. Delivery was prompt. Highly recommend!',
  })
  @IsOptional()
  @IsString()
  @MinLength(10, { message: 'Review description must be at least 10 characters long' })
  description?: string;

  @ApiPropertyOptional({
    description: 'Array of customer review photo/video URLs',
    example: ['https://example.com/uploads/reviews/review1.jpg'],
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  images?: string[];
}
