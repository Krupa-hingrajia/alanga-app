import { IsOptional, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class LowStockQueryDto {
  @ApiProperty({
    required: false,
    default: 10,
    description: 'Stock threshold level. Products with stock below this value are returned.',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  threshold?: number = 10;
}
