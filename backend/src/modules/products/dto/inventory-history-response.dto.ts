import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class InventoryHistoryResponseDto {
  @ApiProperty({ description: 'Inventory History ID', example: 'f3910c22-7711-482a-9e12-4c91a011a011' })
  id: string;

  @ApiProperty({ description: 'Product Variant ID', example: 'var-123' })
  variantId: string;

  @ApiProperty({ description: 'Previous stock count before update', example: 10 })
  previousStock: number;

  @ApiProperty({ description: 'New stock count after update', example: 50 })
  newStock: number;

  @ApiProperty({ description: 'Difference in stock (+/-)', example: 40 })
  quantityChanged: number;

  @ApiProperty({
    description: 'Action type: MANUAL_UPDATE, ORDER_PLACED, ORDER_CANCELLED, RETURN_RECEIVED',
    example: 'MANUAL_UPDATE',
  })
  actionType: string;

  @ApiPropertyOptional({ description: 'Optional remarks or reasons', example: 'Restocked by vendor' })
  remarks?: string | null;

  @ApiProperty({ description: 'User ID of user who updated stock', example: 'usr-123' })
  updatedBy: string;

  @ApiProperty({ description: 'Timestamp when history entry was recorded', example: '2026-08-20T11:30:00.000Z' })
  createdAt: Date;

  constructor(partial: Partial<InventoryHistoryResponseDto>) {
    Object.assign(this, partial);
  }
}
