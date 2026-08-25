import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsArray, IsString } from 'class-validator';

export class UploadProductImagesDto {
  @ApiProperty({
    type: 'array',
    items: { type: 'string', format: 'binary' },
    description: 'Product image files to upload (JPG, JPEG, PNG, WEBP, max 5MB each, max 10 images total per product)',
    required: false,
  })
  @IsOptional()
  files?: any[];

  @ApiProperty({
    type: [String],
    description: 'Optional array of image URLs to add directly',
    example: ['https://example.com/images/prod1.jpg'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  imageUrls?: string[];

  @ApiProperty({
    type: String,
    description: 'Optional Product Variant UUID to attach image to a specific variant',
    example: 'b1c2d3e4-f5a6-7890-1234-56789abcdef0',
    required: false,
  })
  @IsOptional()
  @IsString()
  productVariantId?: string;
}
