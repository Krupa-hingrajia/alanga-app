import { ApiProperty } from '@nestjs/swagger';

export class ProductImageResponseDto {
  @ApiProperty({ example: 'd1e2f3a4-b5c6-7890-1234-56789abcdef0', description: 'Product Image UUID' })
  id: string;

  @ApiProperty({ example: 'a0b1c2d3-e4f5-6789-0123-456789abcdef', description: 'Associated Product UUID' })
  productId: string;

  @ApiProperty({ example: 'b1c2d3e4-f5a6-7890-1234-56789abcdef0', description: 'Associated Product Variant UUID (optional)', required: false, nullable: true })
  productVariantId?: string | null;

  @ApiProperty({ example: '/uploads/products/1724068800000-img1.jpg', description: 'Full URL or path of product image' })
  imageUrl: string;

  @ApiProperty({ example: true, description: 'Indicates if this image is the primary thumbnail' })
  isPrimary: boolean;

  @ApiProperty({ example: 0, description: 'Display order index' })
  displayOrder: number;

  @ApiProperty({ example: '2026-08-19T12:00:00.000Z', description: 'Creation date' })
  createdAt: Date;

  @ApiProperty({ example: '2026-08-19T12:00:00.000Z', description: 'Last update date' })
  updatedAt: Date;
}
