import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, Min, IsOptional, IsString } from 'class-validator';

export class UpdateInventoryDto {
  @ApiProperty({
    description: 'Current total stock quantity for the variant (must be >= 0)',
    example: 50,
    minimum: 0,
  })
  @IsInt()
  @Min(0, { message: 'Current stock cannot be negative.' })
  currentStock: number;

  @ApiPropertyOptional({
    description: 'Minimum threshold stock quantity before triggering low stock alert (must be >= 0)',
    example: 5,
    minimum: 0,
  })
  @IsOptional()
  @IsInt()
  @Min(0, { message: 'Minimum stock cannot be negative.' })
  minimumStock?: number;

  @ApiPropertyOptional({
    description: 'Reason or remarks for the inventory adjustment',
    example: 'Restocked 50 units from warehouse supplier',
  })
  @IsOptional()
  @IsString()
  remarks?: string;
}
