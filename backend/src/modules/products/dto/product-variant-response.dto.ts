import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ProductVariantResponseDto {
  @ApiProperty({ example: '1e3df24a-d65b-4cb0-b54b-2c876eb317d9' })
  id: string;

  @ApiProperty({ example: '8f921a9c-2b47-4903-a129-9e8a7bc12d81' })
  productId: string;

  @ApiProperty({ example: 'TSHIRT-BLK-XL-001' })
  sku: string;

  @ApiProperty({ example: 'Black / XL' })
  variantName: string;

  @ApiPropertyOptional({ example: 'Black', nullable: true })
  color: string | null;

  @ApiPropertyOptional({ example: 'XL', nullable: true })
  size: string | null;

  @ApiPropertyOptional({ example: '128 GB', nullable: true })
  storage: string | null;

  @ApiProperty({ example: 999.0 })
  price: number;

  @ApiProperty({ example: 50 })
  stock: number;

  @ApiProperty({ example: 'ACTIVE' })
  status: string;

  @ApiProperty({ example: '2026-08-20T10:30:00.000Z' })
  createdAt: Date;

  @ApiProperty({ example: '2026-08-20T10:30:00.000Z' })
  updatedAt: Date;
}
