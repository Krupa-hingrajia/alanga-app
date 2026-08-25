import { ApiProperty } from '@nestjs/swagger';

export class InventoryResponseDto {
  @ApiProperty({ description: 'Product Variant object' })
  variant: any;

  @ApiProperty({ description: 'Variant SKU', example: 'ALA-PRD-000001-BLK-M' })
  sku: string;

  @ApiProperty({ description: 'Current total physical stock quantity', example: 50 })
  currentStock: number;

  @ApiProperty({ description: 'Stock reserved by pending orders', example: 5 })
  reservedStock: number;

  @ApiProperty({ description: 'Calculated available stock (currentStock - reservedStock)', example: 45 })
  availableStock: number;

  @ApiProperty({ description: 'Minimum stock threshold for low stock alert', example: 5 })
  minimumStock: number;

  @ApiProperty({
    description: 'Calculated inventory status: IN_STOCK (stock > 10), LOW_STOCK (1..10), OUT_OF_STOCK (0)',
    example: 'IN_STOCK',
    enum: ['IN_STOCK', 'LOW_STOCK', 'OUT_OF_STOCK'],
  })
  inventoryStatus: string;

  @ApiProperty({ description: 'Date/time when stock was last updated', example: '2026-08-20T11:30:00.000Z', nullable: true })
  lastStockUpdatedAt: Date | null;

  @ApiProperty({ description: 'User ID of person who performed last stock update', example: 'usr-123', nullable: true })
  lastStockUpdatedBy: string | null;

  constructor(partial: Partial<InventoryResponseDto>) {
    Object.assign(this, partial);
  }
}
