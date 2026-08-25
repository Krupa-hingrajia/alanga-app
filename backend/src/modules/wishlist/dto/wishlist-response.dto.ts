import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class WishlistResponseDto {
  @ApiProperty({ description: 'Wishlist Item ID (UUID)', example: 'wsh-123-uuid' })
  id: string;

  @ApiProperty({ description: 'Customer ID (UUID)', example: 'cust-456-uuid' })
  customerId: string;

  @ApiProperty({ description: 'Product ID (UUID)', example: 'prd-789-uuid' })
  productId: string;

  @ApiPropertyOptional({ description: 'Product Variant ID (UUID)', example: 'var-101-uuid', nullable: true })
  productVariantId: string | null;

  @ApiProperty({ description: 'Product details' })
  product: any;

  @ApiPropertyOptional({ description: 'Selected Variant details', nullable: true })
  selectedVariant: any | null;

  @ApiProperty({ description: 'Effective Selling Price (Variant or Product)', example: 499 })
  sellingPrice: number;

  @ApiProperty({ description: 'Maximum Retail Price (MRP)', example: 999 })
  mrp: number;

  @ApiProperty({ description: 'Discount Percentage', example: 50 })
  discountPercentage: number;

  @ApiProperty({ description: 'Calculated Stock Status (IN_STOCK, LOW_STOCK, OUT_OF_STOCK)', example: 'IN_STOCK' })
  stockStatus: string;

  @ApiPropertyOptional({ description: 'Embedded Product Shipping Information', nullable: true })
  shipping: any | null;

  @ApiProperty({ description: 'Brand details' })
  brand: any | null;

  @ApiProperty({ description: 'Category details' })
  category: any | null;

  @ApiProperty({ description: 'Created timestamp', example: '2026-08-20T16:45:00.000Z' })
  createdAt: Date;

  @ApiProperty({ description: 'Updated timestamp', example: '2026-08-20T16:45:00.000Z' })
  updatedAt: Date;

  constructor(partial: Partial<WishlistResponseDto>) {
    Object.assign(this, partial);
  }
}
